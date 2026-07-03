# 🔐 Azure Identity & RBAC - Complete Portal Step-by-Step Guide

> Every single click, every field, every screen — documented for Azure Portal beginners.

---

## Table of Contents
1. [Create a New User in Azure AD (Entra ID)](#1-create-a-new-user)
2. [Create a Security Group](#2-create-a-security-group)
3. [Assign RBAC Role to a User](#3-assign-rbac-role-to-a-user)
4. [Create a Service Principal (App Registration)](#4-create-a-service-principal)
5. [Create a Managed Identity](#5-create-a-managed-identity)
6. [Create a Custom Role](#6-create-a-custom-role)
7. [Configure Conditional Access](#7-configure-conditional-access)
8. [Enable PIM (Privileged Identity Management)](#8-enable-pim)
9. [View & Troubleshoot Role Assignments](#9-view-and-troubleshoot-role-assignments)
10. [Common Mistakes & How to Fix Them](#10-common-mistakes)

---

## 1. Create a New User

### What You'll Accomplish
Create a new user account in Microsoft Entra ID (formerly Azure Active Directory).

### Step-by-Step

**Step 1: Navigate to Entra ID**
```
1. Open your browser → Go to https://portal.azure.com
2. Sign in with your admin account
3. In the top search bar, type: "Microsoft Entra ID"
4. Click "Microsoft Entra ID" from the dropdown results
   → You'll see the Entra ID Overview blade
```

**Step 2: Open Users Section**
```
1. In the LEFT sidebar menu, click "Users"
   → You'll see "All users" page with a list of existing users
2. At the top, click "+ New user"
3. A dropdown appears with two options:
   - "Create new user" ← Click this one
   - "Invite external user"
```

**Step 3: Fill in the Basics Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                  │ What to Enter                          │
├─────────────────────────────────────────────────────────────────┤
│ User principal name    │ john.doe (+ select your domain from    │
│                        │ the dropdown, e.g., @company.com)      │
│ Mail nickname          │ Auto-filled (john.doe) — leave as-is   │
│ Display name           │ John Doe                               │
│ Password               │ Choose "Auto-generate password" OR     │
│                        │ "Let me create the password"           │
│ Account enabled        │ ☑ Checked (leave checked)              │
└─────────────────────────────────────────────────────────────────┘
```

**Step 4: Fill in Properties Tab (Optional)**
```
1. Click "Next: Properties" at the bottom
2. Fields you CAN fill (all optional):
   - First name: John
   - Last name: Doe
   - User type: "Member" (default) or "Guest"
   - Job title: DevOps Engineer
   - Department: Engineering
   - Company name: Your Company
   - Usage location: United States (REQUIRED for license assignment!)
3. Leave other fields blank unless needed
```

**Step 5: Fill in Assignments Tab (Optional)**
```
1. Click "Next: Assignments"
2. "+ Add group" → Search for a group → Select it → Click "Select"
3. "+ Add role" → Choose a directory role (e.g., "User Administrator")
   → Only do this if user needs admin privileges
```

**Step 6: Review + Create**
```
1. Click "Next: Review + create"
2. Review all information shown
3. Click "Create" button (blue button at bottom)
4. ✅ You'll see a notification: "User created successfully"
5. IMPORTANT: Copy the temporary password shown (you won't see it again!)
```

---

## 2. Create a Security Group

### What You'll Accomplish
Create a group to organize users for easier RBAC management.

### Step-by-Step

**Step 1: Navigate to Groups**
```
1. In Entra ID left menu → Click "Groups"
   → You'll see "All groups" page
2. Click "+ New group" at the top
```

**Step 2: Fill in Group Details**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field              │ What to Select/Enter                       │
├─────────────────────────────────────────────────────────────────┤
│ Group type         │ "Security" (dropdown — NOT Microsoft 365)  │
│ Group name         │ DevOps-Team                                │
│ Group description  │ DevOps engineers with deployment access    │
│ Microsoft Entra    │ "No" (unless you want approval workflow)   │
│ roles can be       │                                            │
│ assigned           │                                            │
│ Membership type    │ "Assigned" (you pick members manually)     │
│                    │ OR "Dynamic User" (auto based on rules)    │
│ Owner              │ Click "No owners selected" →               │
│                    │ Search your name → Select → Click "Select" │
│ Members            │ Click "No members selected" →              │
│                    │ Search users → Check boxes → "Select"      │
└─────────────────────────────────────────────────────────────────┘
```

**Step 3: Create the Group**
```
1. Click "Create" button at the bottom
2. ✅ Notification: "Group created successfully"
3. The group appears in the "All groups" list
```

---

## 3. Assign RBAC Role to a User

### What You'll Accomplish
Give a user (or group) specific permissions on a Resource Group.

### Step-by-Step

**Step 1: Navigate to Your Resource Group**
```
1. In the portal search bar, type: "Resource groups"
2. Click "Resource groups" from results
3. Click on the resource group you want to assign permissions to
   (e.g., "my-app-rg")
```

**Step 2: Open Access Control (IAM)**
```
1. In the resource group's LEFT menu, click "Access control (IAM)"
   → You'll see the IAM overview page with tabs:
     [Check access] [Role assignments] [Deny assignments] [Roles]
2. Click "+ Add" button at the top
3. From the dropdown, click "Add role assignment"
```

**Step 3: Select the Role (Role Tab)**
```
1. You'll see a list of roles organized in tabs:
   [Job function roles] [Privileged administrator roles]
2. In the search box, type the role you want (e.g., "Contributor")
3. Common roles:
   - Reader: Can view everything, change nothing
   - Contributor: Can create/modify/delete resources (NOT assign roles)
   - Owner: Full access including role assignment
   - Storage Blob Data Reader: Read blobs only
4. Click on the role to highlight it (blue border appears)
5. Click "Next" button at the bottom
```

**Step 4: Assign to Members (Members Tab)**
```
1. "Assign access to" → Select "User, group, or service principal"
   (This is the default selection)
2. Click "+ Select members"
   → A panel opens on the right side
3. In the search box, type the user's name or email
4. Click on the user to select them (checkmark appears)
5. Click "Select" button at the bottom of the panel
6. You'll see the selected member listed
7. Click "Next"
```

**Step 5: Conditions Tab (Optional)**
```
1. For most roles, you'll see "Not applicable"
2. For storage roles, you can add conditions:
   - "Allow user to only assign select roles to select principals"
   - Leave default unless you need fine-grained control
3. Click "Next"
```

**Step 6: Review + Assign**
```
1. Review the summary:
   - Role: Contributor
   - Members: john.doe@company.com
   - Scope: /subscriptions/xxx/resourceGroups/my-app-rg
2. Click "Review + assign" button
3. ✅ Notification: "Role assignment added"
```

### How to Verify the Assignment
```
1. Still on Access control (IAM) page
2. Click the "Role assignments" tab
3. Search for the user's name
4. You'll see: User | Contributor | This resource
```

---

## 4. Create a Service Principal

### What You'll Accomplish
Create an App Registration (Service Principal) for CI/CD pipelines or automation.

### Step-by-Step

**Step 1: Navigate to App Registrations**
```
1. Search bar → Type "App registrations"
2. Click "App registrations" from results
   → You'll see the App registrations page
3. Click "+ New registration" at the top
```

**Step 2: Register the Application**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Name                     │ my-cicd-pipeline                     │
│ Supported account types  │ "Accounts in this organizational    │
│                          │ directory only" (Single tenant)      │
│                          │ ← This is the most common choice    │
│ Redirect URI (optional)  │ Leave blank for service principal    │
└─────────────────────────────────────────────────────────────────┘

Click "Register" button
```

**Step 3: Note the Important IDs**
```
After registration, you'll see the Overview page:
┌────────────────────────────────────────────────────────────┐
│ Application (client) ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx │ ← Copy this!
│ Directory (tenant) ID:   xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx │ ← Copy this!
│ Object ID:               xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx │
└────────────────────────────────────────────────────────────┘
```

**Step 4: Create a Client Secret**
```
1. In the left menu, click "Certificates & secrets"
2. Click the "Client secrets" tab
3. Click "+ New client secret"
4. Fill in:
   - Description: "CI/CD secret"
   - Expires: Choose duration (6 months, 12 months, 24 months, custom)
   ⚠️  WARNING: If this expires, your pipeline breaks! (Lab 02 scenario)
5. Click "Add"
6. 🚨 IMMEDIATELY COPY the "Value" column (shown only ONCE!)
   - The "Secret ID" is NOT the secret value
   - The "Value" is what you use as client_secret
```

**Step 5: Assign RBAC to the Service Principal**
```
1. Go to your Resource Group → Access control (IAM)
2. "+ Add" → "Add role assignment"
3. Select role: "Contributor"
4. Members tab → "Assign access to" → "User, group, or service principal"
5. Click "+ Select members"
6. Search: "my-cicd-pipeline"
7. Select it → "Select" → "Next" → "Review + assign"
```

---

## 5. Create a Managed Identity

### What You'll Accomplish
Create a User-Assigned Managed Identity (reusable across resources).

### Step-by-Step

**Step 1: Search for Managed Identities**
```
1. Portal search bar → Type "Managed Identities"
2. Click "Managed Identities" from results
3. Click "+ Create"
```

**Step 2: Fill in the Basics**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field              │ What to Enter                              │
├─────────────────────────────────────────────────────────────────┤
│ Subscription       │ Select your subscription from dropdown     │
│ Resource group     │ Select existing or "Create new"            │
│ Region             │ Same region as resources using it          │
│                    │ (e.g., East US)                            │
│ Name               │ my-app-identity                            │
└─────────────────────────────────────────────────────────────────┘
```

**Step 3: Tags (Optional)**
```
1. Click "Next: Tags"
2. Add tags if needed:
   - Name: Environment  Value: Production
   - Name: Team         Value: DevOps
```

**Step 4: Review + Create**
```
1. Click "Review + create"
2. Click "Create"
3. ✅ Deployment complete
```

**Step 5: Assign Permissions to the Managed Identity**
```
1. Go to the resource that needs access (e.g., Key Vault)
2. Click "Access control (IAM)" (or "Access policies" for Key Vault)
3. "+ Add" → "Add role assignment"
4. Select role (e.g., "Key Vault Secrets User")
5. Members → "Assign access to" → "Managed identity"
6. Click "+ Select members"
7. Subscription: yours | Managed identity: "User-assigned managed identity"
8. Select "my-app-identity" → "Select"
9. "Review + assign"
```

**Step 6: Attach to a Resource (e.g., VM)**
```
1. Go to your VM → Left menu → "Identity"
2. Click "User assigned" tab
3. Click "+ Add"
4. Search for "my-app-identity"
5. Check the box → Click "Add"
6. ✅ The VM can now use this identity to access resources
```

---

## 6. Create a Custom Role

### What You'll Accomplish
Create a role with specific permissions (not a built-in role).

### Step-by-Step

**Step 1: Navigate to IAM at Subscription Level**
```
1. Search bar → "Subscriptions"
2. Click your subscription
3. Left menu → "Access control (IAM)"
4. Click the "Roles" tab (to see existing roles)
5. Click "+ Add" → "Add custom role"
```

**Step 2: Basics Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                │ What to Enter                            │
├─────────────────────────────────────────────────────────────────┤
│ Custom role name     │ VM Operator                              │
│ Description          │ Can start/stop/restart VMs but not       │
│                      │ create or delete them                    │
│ Baseline permissions │ "Start from scratch"                     │
│                      │ (or "Clone a role" / "Start from JSON")  │
└─────────────────────────────────────────────────────────────────┘

Click "Next"
```

**Step 3: Permissions Tab**
```
1. Click "+ Add permissions"
2. A search panel opens → Type: "Microsoft.Compute/virtualMachines"
3. You'll see a list of permissions. CHECK these:
   ☑ Microsoft.Compute/virtualMachines/start/action
   ☑ Microsoft.Compute/virtualMachines/restart/action
   ☑ Microsoft.Compute/virtualMachines/deallocate/action
   ☑ Microsoft.Compute/virtualMachines/read
   ☑ Microsoft.Compute/virtualMachines/instanceView/read
4. Click "Add"
5. You can add more permissions by repeating "+ Add permissions"
```

**Step 4: Exclude Permissions (Optional)**
```
1. Click "Exclude permissions" tab if you need to deny specific actions
2. Usually leave this empty for custom roles
```

**Step 5: Assignable Scopes Tab**
```
1. Click "Next: Assignable scopes"
2. By default, your current subscription is listed
3. Click "+ Add assignable scopes" to add more subscriptions/RGs
4. You can limit where this role can be assigned
```

**Step 6: JSON Tab (Review)**
```
1. Click "Next: JSON"
2. Review the JSON definition:
   {
     "Name": "VM Operator",
     "Actions": [
       "Microsoft.Compute/virtualMachines/start/action",
       "Microsoft.Compute/virtualMachines/restart/action",
       ...
     ],
     "NotActions": [],
     "AssignableScopes": ["/subscriptions/xxx"]
   }
```

**Step 7: Review + Create**
```
1. Click "Next: Review + create"
2. Click "Create"
3. ✅ Custom role created (may take a few minutes to propagate)
```

---

## 7. Configure Conditional Access

### What You'll Accomplish
Create a policy that requires MFA for specific users/apps.

### Step-by-Step

**Step 1: Navigate to Conditional Access**
```
1. Search bar → "Conditional Access"
2. Click "Microsoft Entra ID Conditional Access"
   → Or: Entra ID → Left menu → "Security" → "Conditional Access"
3. Click "+ Create new policy"
```

**Step 2: Name the Policy**
```
Name: Require MFA for Azure Portal Access
```

**Step 3: Configure Assignments - Users**
```
1. Under "Users", click "0 users and groups selected"
2. Choose:
   - "Select users and groups" (radio button)
   - Check: ☑ "Users and groups"
3. Click the blue "Select" link
4. Search and select target users/groups
5. Click "Select"

Include/Exclude:
- "Include" tab: Who this policy applies TO
- "Exclude" tab: Who is EXEMPT (e.g., break-glass admin accounts)
  ⚠️ ALWAYS exclude at least one emergency access account!
```

**Step 4: Configure Target Resources**
```
1. Under "Target resources", click "No target resources selected"
2. Select what this applies to:
   - "Cloud apps" (most common)
3. Include tab:
   - "Select apps" → Click "Select"
   - Search: "Microsoft Azure Management"
   - Check it → "Select"
   (This covers portal.azure.com, CLI, PowerShell, etc.)
```

**Step 5: Configure Conditions (Optional)**
```
1. Under "Conditions", click "0 conditions selected"
2. Available conditions:
   - Sign-in risk: Low, Medium, High
   - Device platforms: Android, iOS, Windows, macOS
   - Locations: Named locations (e.g., block outside country)
   - Client apps: Browser, Mobile apps, Desktop clients
   - Device state: Compliant, Hybrid Azure AD joined

Example - Location condition:
   1. Click "Locations" → "Configure: Yes"
   2. Include → "Any location"
   3. Exclude → "Selected locations" → "MFA Trusted IPs"
```

**Step 6: Configure Grant Controls**
```
1. Under "Grant", click "0 controls selected"
2. Select "Grant access" (radio button)
3. Check: ☑ "Require multifactor authentication"
4. Other options available:
   - Require device to be marked as compliant
   - Require Hybrid Azure AD joined device
   - Require approved client app
5. "For multiple controls" → "Require all the selected controls"
6. Click "Select"
```

**Step 7: Session Controls (Optional)**
```
1. Under "Session", configure if needed:
   - Sign-in frequency: How often to re-authenticate
   - Persistent browser session: Remember login
2. Usually leave defaults
```

**Step 8: Enable the Policy**
```
1. At the bottom, "Enable policy":
   - "Report-only" ← Start with this! (monitors without enforcing)
   - "On" ← Enforces the policy
   - "Off" ← Disabled
2. Start with "Report-only" to test
3. Click "Create"
4. ✅ Policy created
```

---

## 8. Enable PIM

### What You'll Accomplish
Set up Privileged Identity Management for just-in-time role activation.

### Step-by-Step

**Step 1: Navigate to PIM**
```
1. Search bar → "Privileged Identity Management"
2. Click "Privileged Identity Management"
   → You'll see the PIM dashboard
   ⚠️ Requires Azure AD Premium P2 license!
```

**Step 2: Make a Role Eligible (not permanently active)**
```
1. Click "Azure AD roles" (or "Microsoft Entra roles")
2. Click "Roles" in the left menu
3. Find the role (e.g., "Global Administrator")
4. Click on the role
5. Click "+ Add assignments"
```

**Step 3: Configure the Assignment**
```
Membership tab:
┌─────────────────────────────────────────────────────────────────┐
│ Field              │ What to Select                             │
├─────────────────────────────────────────────────────────────────┤
│ Select member(s)   │ Click "No member selected" →              │
│                    │ Search user → Select → "Select"            │
│ Assignment type    │ "Eligible" (must activate when needed)     │
│                    │ NOT "Active" (permanently on)              │
└─────────────────────────────────────────────────────────────────┘

Click "Next"

Setting tab:
┌─────────────────────────────────────────────────────────────────┐
│ Field                        │ What to Enter                    │
├─────────────────────────────────────────────────────────────────┤
│ Assignment starts            │ Today's date                     │
│ Assignment ends              │ "Eligible permanently" OR        │
│                              │ Set end date (recommended)       │
└─────────────────────────────────────────────────────────────────┘

Click "Assign"
```

**Step 4: Configure Role Settings (Activation Rules)**
```
1. Go back to PIM → Azure AD roles → "Settings"
2. Click on the role (e.g., "Global Administrator")
3. Click "Edit" at the top

Activation tab:
- Maximum activation duration: 8 hours (default)
- Require MFA on activation: ☑ Yes (recommended)
- Require justification: ☑ Yes
- Require ticket information: Optional
- Require approval: ☑ Yes → Select approver(s)

Assignment tab:
- Allow permanent eligible assignment: No (set expiry)
- Expire eligible assignment after: 6 months

Notification tab:
- Send email when members are activated: ☑ Yes
- Send email to: admin@company.com

Click "Update"
```

**Step 5: How a User Activates Their Role**
```
1. User goes to portal → Searches "PIM"
2. Clicks "My roles"
3. Finds "Global Administrator" under "Eligible assignments"
4. Clicks "Activate"
5. Fills in:
   - Duration: 1 hour (up to max allowed)
   - Reason: "Need to modify CA policy for incident #1234"
6. Clicks "Activate"
7. Waits for approval (if required)
8. ✅ Role is active for the specified duration, then auto-deactivates
```

---

## 9. View and Troubleshoot Role Assignments

### Check Who Has Access to a Resource

**Step 1: Check Access on a Resource Group**
```
1. Go to the Resource Group
2. Click "Access control (IAM)"
3. Click "Check access" tab
4. Search for a user/group/service principal
5. You'll see ALL their effective permissions and where they come from:
   - Direct assignment on this RG
   - Inherited from subscription
   - Inherited from management group
```

**Step 2: View All Role Assignments**
```
1. Access control (IAM) → "Role assignments" tab
2. You'll see a table:
   │ Name │ Type │ Role │ Scope │
3. Filter by:
   - Role: Dropdown to filter by specific role
   - Scope: "This resource" or "Inherited"
   - Type: User, Group, Service principal
```

**Step 3: Check for Deny Assignments**
```
1. Access control (IAM) → "Deny assignments" tab
2. Deny assignments OVERRIDE allow assignments
3. Usually created by Azure Blueprints or policies
4. If a user can't do something despite having the role, check here!
```

### Using Azure CLI to Troubleshoot
```bash
# List all role assignments for a user
az role assignment list --assignee john.doe@company.com --output table

# List all role assignments on a resource group
az role assignment list --resource-group my-app-rg --output table

# Check what actions a role allows
az role definition list --name "Contributor" --output json

# Find who has Owner on a subscription
az role assignment list --role "Owner" --scope "/subscriptions/YOUR-SUB-ID"
```

---

## 10. Common Mistakes

### ❌ Mistake 1: Assigned Role at Wrong Scope
```
Problem: User can access ResourceGroup-A but not ResourceGroup-B
Why: Role was assigned on RG-A, not the subscription
Fix: Assign at subscription level, or assign separately on each RG

To check:
1. Go to the resource where access fails
2. IAM → Check access → Search user
3. If no assignment shown → Need to add one at this scope
```

### ❌ Mistake 2: Service Principal Secret Expired
```
Problem: CI/CD pipeline suddenly fails with "unauthorized"
Why: Client secret has an expiry date!

To check:
1. Entra ID → App registrations → Find the app
2. Click "Certificates & secrets"
3. Look at the "Expires" column
4. If expired → Create new secret → Update pipeline config
```

### ❌ Mistake 3: Using Owner When Contributor is Enough
```
Problem: Security team flags over-privileged accounts
Why: Owner can assign roles to others (privilege escalation risk)

Fix:
1. IAM → Role assignments → Find the user with Owner
2. Remove the Owner assignment
3. Add Contributor assignment instead
4. If they need to assign roles: Use "User Access Administrator" + Contributor
```

### ❌ Mistake 4: Managed Identity Not Assigned to Resource
```
Problem: App returns "DefaultAzureCredential failed"
Why: Created the identity but forgot to attach it

To check:
1. Go to your App Service/VM/Function
2. Left menu → "Identity"
3. System assigned: Status must be "On"
   OR User assigned: Must have an identity listed
4. If missing → Enable/Add it
5. Also check: Does the identity HAVE a role assignment?
```

### ❌ Mistake 5: Forgot to Exclude Break-Glass Account from Conditional Access
```
Problem: ALL admins locked out of the portal
Why: Conditional Access policy requires MFA, MFA service is down

Prevention:
1. Create 2 "break-glass" accounts (no MFA, complex passwords)
2. EVERY Conditional Access policy → Exclude → Add break-glass accounts
3. Monitor sign-ins for these accounts (should never be used normally)
```

---

## 📋 Quick Reference Card

| Task | Portal Path |
|------|-------------|
| Create user | Entra ID → Users → + New user |
| Create group | Entra ID → Groups → + New group |
| Assign RBAC | Resource → IAM → + Add → Add role assignment |
| App registration | Entra ID → App registrations → + New registration |
| Managed Identity | Search "Managed Identities" → + Create |
| Custom Role | Subscription → IAM → + Add → Add custom role |
| Conditional Access | Security → Conditional Access → + New policy |
| PIM | Search "PIM" → Azure AD roles → Roles |
| Check access | Resource → IAM → Check access tab |
| View assignments | Resource → IAM → Role assignments tab |

---

## 🔗 Related Labs
- [Lab 01: RBAC Access Denied](../lab-01-rbac-access-denied/)
- [Lab 02: Service Principal Expired](../lab-02-service-principal-expired/)
- [Lab 03: Managed Identity Not Working](../lab-03-managed-identity-not-working/)
- [Lab 04: Conditional Access Blocking](../lab-04-conditional-access-blocking/)
- [Lab 05: PIM Activation Failed](../lab-05-pim-activation-failed/)
- [Lab 06: Custom Role Too Restrictive](../lab-06-custom-role-too-restrictive/)
- [Lab 07: Subscription Policy Blocking](../lab-07-subscription-policy-blocking/)
- [Lab 08: Key Vault Access Denied](../lab-08-key-vault-access-denied/)
