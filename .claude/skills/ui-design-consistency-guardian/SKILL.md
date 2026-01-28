---
name: ui-design-consistency-guardian
description: A skill that ensures UI/UX consistency during design changes, preventing visual inconsistencies, cut-off elements, layout issues, and maintaining a cohesive design language across all components and pages.
when-to-use: When making any UI/UX changes, after visual overhauls, when adding new components to existing designs, or when you need to ensure design system adherence across multiple pages or features.
capabilities:
  - Audit design changes for visual consistency violations
  - Identify and flag cut-off, overlapping, or misaligned elements
  - Validate spacing, padding, and margin consistency across components
  - Ensure color palette and typography usage follows established design tokens
  - Check responsive design patterns and breakpoint behavior
  - Detect accessibility issues related to visual design (contrast, focus states)
  - Maintain component state consistency (hover, active, disabled states)
  - Verify icon style and sizing uniformity
  - Ensure proper hierarchy and visual weight distribution
  - Validate interaction patterns match existing design language
---

# UI Design Consistency Guardian

## Purpose

This skill ensures that all UI/UX changes maintain visual consistency and adhere to established design patterns. It acts as a quality gate during design iterations, preventing common issues like visual drift, broken layouts, cut-off content, and inconsistent styling.

## How It Works

When you invoke this skill, it will:
1. Analyze the existing design context and established patterns
2. Review proposed changes against the current design system
3. Identify any inconsistencies, visual issues, or UX problems
4. Provide specific recommendations to maintain consistency
5. Generate corrected versions when needed

## Key Consistency Checks

### Visual Elements
- **Typography**: Font families, sizes, weights, line heights, and letter-spacing
- **Colors**: Primary, secondary, accent colors, and semantic color usage (success, warning, error)
- **Spacing**: Consistent padding, margins, and gap sizes following the spacing scale
- **Borders & Shadows**: Consistent border radii, border widths, and shadow elevations
- **Icons**: Matching icon style (filled/outline), stroke width, and sizing

### Layout & Structure
- **Grid Systems**: Proper alignment to established columns and gutters
- **Component Hierarchy**: Correct nesting and parent-child relationships
- **Whitespace**: Consistent breathing room between sections and elements
- **Responsiveness**: Proper behavior across breakpoints (mobile, tablet, desktop)

### Interaction States
- **Hover Effects**: Consistent hover states across interactive elements
- **Active/Focus States**: Proper focus indicators and active state styling
- **Disabled States**: Clear visual feedback for disabled components
- **Loading States**: Consistent loading patterns and skeletons

### Common Issues Detected
- Cut-off text or overlapping elements
- Misaligned buttons or form fields
- Inconsistent button sizes or styles
- Broken responsive layouts
- Missing focus states for accessibility
- Inconsistent card or container shadows
- Mismatched icon styles within the same context
- Typography hierarchy violations

## Usage Examples

### Example 1: After a Visual Overhaul

**User Request:**
```
I just updated the button styles across the app. Please use the ui-design-consistency-guardian to check if everything looks consistent.
```

**Skill Response:**
I'll audit the button consistency across your application.

**Consistency Issues Found:**
1. **Inconsistent Sizes**: Primary buttons in the navigation are 44px tall, while primary buttons in forms are 40px tall
2. **Border Radius Mismatch**: Navigation buttons use 8px radius, but form buttons use 4px
3. **Icon Alignment**: Buttons with icons have inconsistent icon-to-text spacing (8px vs 12px)

**Recommendations:**
- Standardize all primary buttons to 44px height with 8px border radius
- Set consistent icon spacing to 12px for all icon-button combinations
- Update disabled state to match the new color scheme

Would you like me to generate the corrected CSS/components?

### Example 2: Adding New Components

**User Request:**
```
I'm creating a new notification card component. Use ui-design-consistency-guardian to ensure it matches our existing card designs.
```

**Skill Response:**

**Design System Reference:**
- Card shadow: `box-shadow: 0 2px 8px rgba(0,0,0,0.1)`
- Card padding: 24px
- Border radius: 12px
- Card border: `1px solid #E5E7EB`

**Consistency Checklist for Notification Card:**

| Element | Your Design | Design System | Status |
|---------|-------------|---------------|--------|
| Shadow | `0 4px 12px rgba(0,0,0,0.15)` | `0 2px 8px rgba(0,0,0,0.1)` | ❌ Inconsistent |
| Padding | 20px | 24px | ❌ Inconsistent |
| Border Radius | 8px | 12px | ❌ Inconsistent |
| Border | `1px solid #D1D5DB` | `1px solid #E5E7EB` | ❌ Inconsistent |
| Title Typography | 16px/600 | 18px/600 | ❌ Inconsistent |
| Body Typography | 14px/400 | 14px/400 | ✅ Consistent |

**Issues Detected:**
1. The card shadow is too heavy compared to other cards in the system
2. Padding is 4px less than standard, creating visual imbalance
3. Border radius doesn't match the card family
4. Title should be 18px to maintain proper hierarchy

**Corrected Component:**
[Provides updated code/design matching design system]

### Example 3: Layout Consistency Check

**User Request:**
```
Check this dashboard page for any visual issues or inconsistencies.
```

**Skill Response:**

**Layout Audit Results:**

**Critical Issues:**
1. **Cut-off Content**: The "Recent Activity" section's last row is partially hidden at the bottom on 1366x768 screens
2. **Misaligned Grid**: The stats cards aren't aligned to the 12-column grid (first card starts at column 1.5)
3. **Overlapping Elements**: The notification badge overlaps the user avatar in the header

**Consistency Violations:**
1. **Inconsistent Card Heights**: Stats cards vary between 120px-140px; should all be 140px for alignment
2. **Spacing Drift**: Section spacing is 40px in some areas, 48px in others (should be 48px)
3. **Typography Inconsistency**: Section headers use 24px in top section, 20px in bottom section

**Recommendations:**
- Add `min-height` to Recent Activity or implement pagination
- Rebuild stats grid using proper 12-column alignment
- Adjust header layout with proper spacing calculations
- Standardize all section headers to 24px with 8px bottom margin
- Apply consistent 48px vertical spacing between all major sections

### Example 4: Responsive Design Verification

**User Request:**
```
I updated the mobile layout. Check for consistency and issues.
```

**Skill Response:**

**Responsive Design Consistency Check:**

**Mobile (≤ 768px):**
- ✅ Hamburger menu properly positioned
- ❌ Primary buttons too small (32px height - minimum 44px for touch)
- ❌ Form fields overlap with virtual keyboard
- ❌ Cards stacked with inconsistent gaps (16px, 20px, 16px)

**Tablet (769px - 1024px):**
- ✅ Grid adapts properly from 3 columns to 2
- ❌ Navigation items cut off in landscape mode
- ❌ Modal dialogs overflow viewport width

**Desktop (≥ 1025px):**
- ✅ All elements properly aligned
- ✅ Hover states working correctly

**Critical Fixes Needed:**
1. Increase all touch targets to minimum 44x44px
2. Add proper spacing to prevent keyboard overlap in forms
3. Standardize mobile card gaps to 16px
4. Implement horizontal scroll or wrap for tablet navigation
5. Add max-width constraints to modals with overflow handling

## Design System Reference Template

When this skill activates, it references the following design system structure:

```yaml
design_tokens:
  colors:
    primary:
      base: "#3B82F6"
      hover: "#2563EB"
      active: "#1D4ED8"
    neutral:
      50: "#F9FAFB"
      100: "#F3F4F6"
      # ... etc
  typography:
    font_family:
      heading: "Inter, sans-serif"
      body: "Inter, sans-serif"
    font_size:
      xs: "12px"
      sm: "14px"
      base: "16px"
      lg: "18px"
      xl: "20px"
      "2xl": "24px"
      "3xl": "30px"
    font_weight:
      regular: 400
      medium: 500
      semibold: 600
      bold: 700
  spacing:
    xs: "4px"
    sm: "8px"
    md: "16px"
    lg: "24px"
    xl: "32px"
    "2xl": "48px"
    "3xl": "64px"
  border_radius:
    sm: "4px"
    md: "8px"
    lg: "12px"
    xl: "16px"
    full: "9999px"
  shadows:
    sm: "0 1px 2px rgba(0,0,0,0.05)"
    md: "0 4px 6px rgba(0,0,0,0.07)"
    lg: "0 10px 15px rgba(0,0,0,0.1)"
  z_index:
    dropdown: 1000
    sticky: 1020
    fixed: 1030
    modal_backdrop: 1040
    modal: 1050
    popover: 1060
    tooltip: 1070
```

## Success Criteria

The skill has successfully maintained consistency when:
- ✅ All visual elements follow the established design tokens
- ✅ No cut-off, overlapping, or misaligned elements exist
- ✅ Spacing and typography are consistent across all components
- ✅ All interactive states (hover, active, focus, disabled) are properly styled
- ✅ Responsive behavior works correctly across all breakpoints
- ✅ Accessibility standards (contrast, focus indicators, touch targets) are met
- ✅ New components blend seamlessly with existing designs

## Failure Modes

This skill may not catch:
- Very subtle visual inconsistencies that require human aesthetic judgment
- Brand-new design patterns that haven't been established yet
- Performance issues related to the implementation
- Backend or functionality problems unrelated to visual design

In these cases, combine with other skills or manual review for comprehensive coverage.