# `hpe_morpheus_user`: "Provider produced inconsistent result after apply" for `role_ids` when assigning a multitenant role to a subtenant user

### Provider version
`hpe/hpe` v1.5.0

### Terraform version
v1.12.2

### Affected resource
`hpe_morpheus_user`

---

## Summary

When a `hpe_morpheus_user` in a **subtenant** is assigned a role that is owned by the
**master** tenant and marked `multitenant = true`, Terraform fails the apply with:

```
Error: Provider produced inconsistent result after apply

When applying changes to hpe_morpheus_user.example, provider
"provider[\"registry.terraform.io/hpe/hpe\"].master-tenant" produced an
unexpected new value: .role_ids: planned set element cty.NumberIntVal(287)
does not correlate with any element in actual.

This is a bug in the provider, which should be reported in the provider's own
issue tracker.
```

The error occurs on **create**. Because the create path taints the resource on
error, subsequent applies re-plan a replacement and hit the same error again,
so the configuration can never converge.

## Root cause

Morpheus does not assign the master role's ID to a subtenant user. When a
`multitenant = true` master role is assigned to a user in a subtenant, Morpheus
resolves it to that **subtenant's per-tenant copy of the role**, which has a
**different ID**. The provider then writes that copy ID back into state, but the
schema declares `role_ids` as `Required` (a known, plan-time value), so Terraform
core detects that the planned value changed after apply.

Relevant code (ref `1705dcf`):

1. **`role_ids` is `Required`, not `Computed`, and has no plan modifiers** —
   `morpheus/framework/resources/user/schema_gen.go`:
   ```go
   "role_ids": schema.SetAttribute{
       ElementType: types.Int64Type,
       Required:    true,
   },
   ```

2. **Create sends the configured IDs** —
   `morpheus/framework/resources/user/resource.go` (`Create`):
   ```go
   for _, roleID := range roleIDs {
       rolevalue := sdk.AddUserRequestUserRolesInner{ Id: &roleID }
       roles = append(roles, rolevalue)
   }
   addUser.Roles = roles
   ```

3. **After POST, state is rebuilt from the API response** — `Create` calls
   `getUserAsState(ctx, id, client)`, which overwrites `role_ids` with whatever
   IDs the API returns (the tenant copy IDs):
   ```go
   roleIDValues := []attr.Value{}
   for _, role := range u.User.Roles {
       roleIDValues = append(roleIDValues, convert.Int64ToType(role.Id))
   }
   roleIDSet, d := types.SetValue(types.Int64Type, roleIDValues)
   ...
   state.RoleIds = roleIDSet
   ```

Planned `role_ids` (configured master role ID) ≠ final `role_ids` (subtenant
copy ID) ⇒ `objchange.AssertObjectCompatible` reports the inconsistency and
Terraform core turns it into the hard error above.

## Steps to reproduce

1. Create a master-owned role with `multitenant = true`.
2. Create a subtenant.
3. Create a user **in the subtenant** and set `role_ids = [<master_role>.id]`.

```hcl
# master-owned, multitenant role
resource "hpe_morpheus_role" "example_role" {
  name        = "Example Role"
  multitenant = true
  role_type   = "user"
  provider    = hpe.master-tenant
}

resource "hpe_morpheus_tenant" "sub" {
  name         = "Sub"
  subdomain    = "sub"
  base_role_id = hpe_morpheus_role.some_base_role.id
  provider     = hpe.master-tenant
}

resource "hpe_morpheus_user" "example" {
  tenant_id           = hpe_morpheus_tenant.sub.id
  username            = "example"
  email               = "example@testacc.com"
  password_wo         = var.password
  password_wo_version = 1
  role_ids            = [hpe_morpheus_role.example_role.id] # master ID; Morpheus assigns the copy
  provider            = hpe.master-tenant
}
```

`terraform apply` ⇒ "Provider produced inconsistent result after apply: .role_ids".

## Expected behavior

Assigning a `multitenant` master role to a subtenant user should succeed, with
the provider reconciling the returned per-tenant role ID against the configured
master role ID (or otherwise not tripping the post-apply consistency check).

## Actual behavior

The apply errors on create, and the resource is left tainted, so it is replaced
(and re-errors) on every subsequent apply.

## Suggested fixes (any one)

- Normalize/reconcile the API-returned role IDs against the configured IDs in
  `getUserAsState` for the multitenant-copy case, so the value written to state
  matches the plan.
- Or make `role_ids` `Optional + Computed` with a `UseStateForUnknown` plan
  modifier so the API-derived value doesn't trip the plan/apply consistency check.
- At minimum, document this limitation for multitenant roles + subtenant users.

## Workaround (for reference)

Force `role_ids` to be **unknown at plan** on create (so Terraform skips the
consistency check), while still sending the correct master role ID at apply, then
pin the returned copy ID with `ignore_changes`:

```hcl
resource "terraform_data" "example_role_ref" {
  input = hpe_morpheus_role.example_role.id
}

resource "hpe_morpheus_user" "example" {
  # ...
  role_ids = [terraform_data.example_role_ref.output]
  lifecycle {
    ignore_changes = [role_ids]
  }
}
```

For **regular** subtenant users, a cleaner alternative is to look up the tenant's
role copy via a `hpe_morpheus_role` **data source** through a subtenant-scoped
provider (so the planned ID already equals the copy ID). This does not work for
the first/admin user of a tenant, because the subtenant provider authenticates as
that very user (bootstrap circularity) — hence the `terraform_data` workaround
above.
