---
name: implementation-verifier
description: Validates that all existing features, components, and functionality in an application are fully implemented and working as intended
when-to-use: Before releases, after major refactoring, when onboarding to a new codebase, or as part of quality assurance processes
capabilities:
  - Perform comprehensive feature completeness audits
  - Validate component functionality against specifications
  - Test end-to-end user flows and interactions
  - Verify integration points between modules
  - Check error handling and edge cases
  - Validate accessibility compliance of implemented features
  - Verify responsive behavior across viewports
  - Identify gaps between implementation and requirements
  - Generate detailed validation reports with action items
---

# Implementation Verifier Skill

## Overview

This skill systematically validates that all implemented features, components, and functionality in an application are complete, working as intended, and meeting all requirements. It focuses on actual code and functionality—NOT todos, comments, or documentation placeholders.

## How It Works

The verification process follows a structured approach:

### 1. Discovery Phase
- Identify all implemented features and components
- Map component hierarchy and dependencies
- Document user flows and interactions
- List all integration points

### 2. Validation Phase
- **Functionality Check**: Verify each feature performs its intended purpose
- **Completeness Check**: Confirm no partial implementations exist
- **Integration Check**: Validate data flow between components/modules
- **Edge Case Coverage**: Test error handling and boundary conditions
- **Accessibility Check**: Verify WCAG compliance for interactive elements
- **Responsive Check**: Confirm behavior across device sizes

### 3. Reporting Phase
- Generate comprehensive validation report
- Identify any gaps or issues found
- Provide actionable recommendations
- Mark features as: ✓ Verified | ⚠ Partial | ✗ Issues Found

## Usage Examples

### Example 1: Complete App Audit

```
Please perform a comprehensive implementation audit of this e-commerce application:

- Check all user-facing features (product browsing, cart, checkout, user accounts)
- Validate admin panel functionality
- Verify payment integration
- Test responsive behavior on mobile/tablet/desktop
- Check accessibility compliance
- Generate a detailed report with findings
```

**Expected Output:**
```
# Implementation Validation Report

## Summary
- Total Features Validated: 24
- Fully Implemented: 21 (87.5%)
- Partial Implementation: 2 (8.3%)
- Issues Found: 1 (4.2%)

## Feature-by-Feature Results

### ✓ Product Browsing
- Status: FULLY IMPLEMENTED
- Verified: Product listing, search, filtering, sorting, pagination
- User Flow: Working end-to-end
- Responsive: Mobile ✓ Tablet ✓ Desktop ✓
- Accessibility: Keyboard navigation ✓ ARIA labels ✓ Focus management ✓

### ⚠ User Authentication
- Status: PARTIAL IMPLEMENTATION
- Working: Login, registration, password reset
- Missing: Two-factor authentication, social login providers
- Issue: Password reset flow has a race condition (details below)

### ⚠ Order History
- Status: PARTIAL IMPLEMENTATION
- Working: Basic order list display
- Missing: Order status tracking, re-order functionality, export to PDF

### ✗ Payment Processing
- Status: ISSUES FOUND
- Critical: Credit card validation failing for international formats
- Issue: Stripe integration error handling not covering gateway timeout
- Details: See "Critical Issues" section below

## Critical Issues Requiring Immediate Attention

1. Payment Gateway Timeout Handling
   - Location: src/services/payment.js:145-162
   - Issue: Unhandled promise rejection on gateway timeout
   - Impact: Users see generic error, payment status uncertain
   - Recommendation: Add retry logic with user notification
```

### Example 2: Component-Specific Validation

```
Verify the completeness and functionality of the dashboard components:

- Data visualization widgets (charts, graphs)
- Real-time status indicators
- Notification system
- User preferences panel
- Data export functionality
```

### Example 3: Post-Refactoring Validation

```
After the recent state management refactoring, verify that:

- All existing features still work as before
- No functionality was accidentally removed
- Component interactions are functioning correctly
- Data persistence is working
- User sessions are maintained properly
```

## Validation Checklist

When invoked, this skill automatically checks:

### Core Functionality
- [ ] All buttons/actions trigger expected behavior
- [ ] Forms validate and submit correctly
- [ ] Data displays accurately and updates appropriately
- [ ] Navigation works throughout the application
- [ ] State changes reflect correctly in the UI

### User Flows
- [ ] Critical user paths complete successfully
- [ ] Back/forward navigation maintains state
- [ ] Error states are handled gracefully
- [ ] Loading states display appropriately
- [ ] Success/failure feedback is clear to users

### Integrations
- [ ] API calls complete with proper handling
- [ ] External services connect correctly
- [ ] Data passes between modules accurately
- [ ] Authentication/authorization is enforced
- [ ] Third-party libraries function as expected

### Quality Standards
- [ ] No console errors or warnings
- [ ] Performance is acceptable (load times, responsiveness)
- [ ] Memory leaks not present
- [ ] Accessibility standards met (WCAG 2.1 AA minimum)
- [ ] Responsive design works across breakpoints

## What This Skill Does NOT Check

- ❌ TODO comments or task lists
- ❌ Code comments or documentation
- ❌ Planned features not yet implemented
- ❌ Developer notes or placeholder text
- ❌ Code style or formatting (use a linter)
- ❌ Test coverage (use a coverage tool)

## Best Practices

1. **Be Specific**: Provide clear scope for what to validate
2. **Include Context**: Share any relevant specs or requirements
3. **Define Users**: Mention which user roles/flows matter most
4. **Set Priority**: Identify critical vs. nice-to-have functionality
5. **Provide Access**: Ensure codebase is available for review

## Common Validation Scenarios

| Scenario | What to Validate |
|----------|-----------------|
| Pre-release | All user-facing features, critical paths, payment flows |
| Post-refactoring | Previously working functionality, state management, data flow |
| Post-integration | New API connections, third-party services, data sync |
| Accessibility audit | Keyboard navigation, screen readers, color contrast, focus |
| Mobile audit | Touch interactions, viewport handling, mobile-specific features |

## Output Format

All validations produce a structured report containing:

1. **Executive Summary** - Quick overview of validation status
2. **Detailed Results** - Feature-by-feature breakdown
3. **Issues Found** - Categorized by severity
4. **Recommendations** - Actionable next steps
5. **Confidence Score** - Assessment of verification thoroughness

## Limitations

- Cannot execute actual automated tests (relies on code analysis)
- Cannot validate visual design without screenshots/deployment
- Performance testing is approximate, not measured
- Security validation is functional only (not a security audit)