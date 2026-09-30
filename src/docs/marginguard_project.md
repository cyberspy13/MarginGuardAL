# MarginGuard — a cross-module Business Central AL practice project

**Level:** medium → advanced
**Modules touched:** Purchase, Manufacturing, Sales, Finance
**Goal:** not just "extend a table and add a page" — force yourself through interfaces, events, permission sets as AL objects, modern error handling, background jobs, and automated tests, all glued together by one coherent business problem.

---

## 1. The scenario

**Fabrikam Bikes Ltd** assembles bicycles from purchased components. Management has a real, recognisable pain: nobody notices when a purchasing decision, a shop-floor variance, or a generous discount quietly turns a "profitable" sales order into a loss — until the month-end numbers land wrong.

You are building **MarginGuard**, an extension that:

1. Captures the *true* landed cost of purchased components (not just the invoice price) and accrues vendor rebates automatically — **Purchase**.
2. Tracks the gap between standard and actual production cost, and stops a bad component lot from being consumed — **Manufacturing**.
3. Blocks or warns on sales orders that would sell below a real cost-plus-margin threshold, and applies customer loyalty tiers — **Sales**.
4. Posts all of the above as proper G/L entries with dimensions, and rolls it all up into a profitability view — **Finance**.

Nothing here is a toy CRUD exercise. Every feature only makes sense because of what happened in a *different* module — that's what makes this "medium leaning advanced": the difficulty isn't any single object, it's the wiring between them.

---

## 2. AL principles coverage matrix

Use this as your personal checklist. If you finish the project and can't point to a concrete object for every row, that's your signal for what to add before calling it done.

| Principle | Where you'll practice it | Module(s) |
|---|---|---|
| Object naming & ID ranges (`app.json` ranges, consistent prefixing) | Every object in the app | All |
| Interfaces + enums instead of `CASE` chains, for true extensibility | Rebate calculation strategy, margin policy | Purchase, Sales |
| Integration events (publish + subscribe) for decoupling | Landed cost allocation, rebate calc, margin check | Purchase, Manufacturing, Sales |
| Modern error handling with `ErrorInfo` and recall actions | Quality hold block, margin block | Manufacturing, Sales |
| Permission sets as AL objects (not XML) | Rebate admin, margin override | Purchase, Sales |
| Setup singleton table pattern (`Get`/`Insert`) | `MarginGuard Setup` | All |
| Background processing via Job Queue | Monthly rebate accrual batch | Purchase/Finance |
| Telemetry (`Session.LogMessage`) | Variance and rebate calculations | Manufacturing/Finance |
| FlowFields, FlowFilters, and Query objects | Customer YTD spend, profitability rollup | Sales/Finance |
| Performance discipline (`SetLoadFields`, temp tables, avoiding nested loops) | Allocation loop, profitability query | Purchase/Finance |
| AL test codeunits with the standard Library pattern | Regression suite | All |
| API pages/queries | Profitability export | Finance |
| Report extensions | Purchase order showing landed cost | Purchase |
| Table/page extensions vs. new tables (knowing which) | Throughout | All |
| Dimensions handled correctly on journal postings | Rebate and variance G/L entries | Finance |

---

## 3. Module-by-module feature breakdown

### 3.1 Purchase

**Feature A — Landed cost allocation**
- New table `Landed Cost Component` (Purchase Header link, Charge Type enum: Freight/Duty/Insurance, Amount).
- Table extension on `Purch. Inv. Header`: `Landed Cost Status` (enum: Pending / Allocated / Posted).
- Codeunit that allocates the extra charges across purchase lines — implement it twice, by **value** and by **weight**, selected through your first `interface`. This is the natural place to introduce interfaces before you need them for rebates.
- Hook the allocation into posting via an **event subscriber**, not by modifying standard code.
- Use `ErrorInfo` with a recall action if a posted invoice has no landed cost setup ("Fix landed cost setup" action).

**Feature B — Vendor rebate agreements**
- Setup table `Vendor Rebate Agreement` (Vendor No., Item Category, Threshold Qty/Amount, Rebate %, Valid From/To).
- Ledger-style table `Vendor Rebate Ledger Entry` (Entry No., Posting Date, Vendor No., Amount, Applied/Unapplied) — model it like a real ledger, not a working table.
- `interface IRebateCalculationStrategy` with two codeunit implementations: **Volume Based** and **Tiered**. This is the extensibility pattern you'll reuse conceptually in Sales.
- A monthly **Job Queue** entry that recalculates accrued rebates for all vendors — your first background job.
- A dedicated **permission set** object, `MG Purchase Rebate Admin`, scoped to just the rebate tables/pages.

### 3.2 Manufacturing

**Feature A — Actual vs. standard cost variance**
- Subscribe to the output/finish posting events on production orders to compare standard cost against actual cost (including the landed cost rolled up from Purchase — this is your first real cross-module dependency).
- New table `Production Cost Variance Entry`: production order no., work center, variance amount, cause (enum: Material / Labor / Overhead).
- A review page with a simple status enum (Open / Approved / Posted) before a variance is allowed to post to the G/L — a lightweight approval gate, no need for the full Workflow engine unless you want the stretch goal.

**Feature B — Quality hold**
- Table extension adding `Quality Status` (enum: Pending Inspection / Passed / Failed) to the relevant ledger/lot tracking.
- Validation logic that stops a failed lot from being consumed on a production journal line, raised as `ErrorInfo` with an action that opens the inspection record — not a bare `Error('text')`.
- A purchase receipt should be able to spin up a `Quality Inspection` record automatically — this is the second cross-module bridge (Purchase → Manufacturing).

### 3.3 Sales

**Feature A — Margin protection engine**
- Codeunit `Sales Margin Guard` subscribing to sales line validation, computing real-time margin using *actual* cost (landed cost + variance), not just standard cost.
- Threshold comes from a setup field, not a hardcoded constant.
- Below threshold: warn or block depending on the user's permission set (a Sales Manager can override; a junior user can't) — this is where the permission set design actually matters functionally, not just for security theatre.
- A second `interface IMarginPolicy` lets different customer groups apply different margin rules — same extensibility pattern as the rebate strategy, applied independently so you build the muscle memory twice.

**Feature B — Customer loyalty tiers**
- Table `Customer Loyalty Tier` (Bronze/Silver/Gold) driven by a FlowField on YTD purchase amount.
- A batch job assigns tiers, which then feeds into price/discount calculation via an event subscriber on the sales price lookup — practice FlowFields, a Query object, and event-driven price logic together.

### 3.4 Finance

**Feature A — Automated G/L postings**
- Codeunit `Rebate GL Posting Mgt.` posts accrued vendor rebates and customer loyalty discounts through `Gen. Jnl.-Post Line`, not direct table writes.
- Carry dimensions through correctly (global/shortcut dimensions copied from source documents) — this trips up almost everyone the first time.
- Setup-table-driven G/L account selection for rebates — no hardcoded account numbers.

**Feature B — Profitability cockpit**
- A `query` object joining sales, purchase cost, production variance, and rebate ledger entries.
- A page (ideally a Role Center part with a chart) showing profitability by item/customer/vendor.
- An **API page or query** exposing the same data — this is your Power BI / external-consumption practice.
- A **report extension** on the standard Purchase Order report to show landed cost per line.

---

## 4. Suggested object list & ID plan

Pick your own range (a throwaway range like 50100–50199 is fine for practice; if you ever plan to publish to AppSource you'd need a registered affix instead). Rough shape:

| Range | Objects |
|---|---|
| 50100–50119 | Enums (Charge Type, Rebate Calculation Type, Variance Cause, Quality Status, Review Status) |
| 50120–50139 | Tables (Landed Cost Component, Vendor Rebate Agreement, Vendor Rebate Ledger Entry, Production Cost Variance Entry, Customer Loyalty Tier, MarginGuard Setup) |
| 50140–50149 | Table/page extensions |
| 50150–50169 | Codeunits (allocation, rebate strategies, margin guard, GL posting, job queue logic) |
| 50170–50179 | Interfaces |
| 50180–50189 | Pages (setup, list/card pages, cockpit) |
| 50190–50194 | Reports & report extensions |
| 50195–50197 | API pages/queries |
| 50198–50199 | Permission sets |

---

## 5. Build roadmap

Work in this order — each phase depends on the previous one existing, which is deliberate; it mirrors how you'd actually have to sequence this in a real project.

1. **Foundation** — `app.json`, enums, the `MarginGuard Setup` singleton table + page, permission sets scaffolded early (empty is fine, fill in as you go).
2. **Purchase: landed cost** — table, allocation codeunit with the value/weight interface, event subscriber into posting, `ErrorInfo` for missing setup.
3. **Purchase: rebates** — agreement table, ledger table, `IRebateCalculationStrategy` + two implementations, Job Queue entry, permission set.
4. **Manufacturing** — variance table + review page, quality status field + block logic with `ErrorInfo`, the Purchase→Manufacturing quality inspection bridge.
5. **Sales** — margin guard codeunit + `IMarginPolicy`, loyalty tier table + FlowField + batch job + price event subscriber.
6. **Finance** — GL posting codeunit with dimensions, profitability query + cockpit page, API page, report extension.
7. **Testing & telemetry** — AL test codeunits per module using the standard Library pattern, `Session.LogMessage` on the calculation-heavy codeunits.
8. **Stretch** — Power BI-ready dataset, approval workflow for variances using the real Workflow feature, an upgrade codeunit for a deliberate schema change.

At the end of each phase, ask yourself: *could a partner extend this further without touching my code?* If the answer is no, you probably wrote a `CASE` statement where an event or interface belonged.

---

## 6. Starter patterns

These are skeletons to illustrate the *shape* of each pattern — not copy-paste-complete code. Field names, exact base-app event names, and signatures vary by BC version, so verify against the symbol browser or Microsoft Learn for whatever version you're on before relying on them.

### 6.1 Interface + enum extensibility (rebate calculation)

```al
interface "Rebate Calculation Strategy"
{
    procedure CalculateRebate(VendorNo: Code[20]; PeriodAmount: Decimal): Decimal;
}

enum 50100 "Rebate Calculation Type"
{
    Extensible = true;

    value(0; "Volume Based") { Caption = 'Volume Based'; }
    value(1; "Tiered") { Caption = 'Tiered'; }
}

codeunit 50150 "Volume Based Rebate" implements "Rebate Calculation Strategy"
{
    procedure CalculateRebate(VendorNo: Code[20]; PeriodAmount: Decimal): Decimal
    var
        Agreement: Record "Vendor Rebate Agreement";
    begin
        Agreement.SetRange("Vendor No.", VendorNo);
        if Agreement.FindFirst() then
            if PeriodAmount >= Agreement."Threshold Amount" then
                exit(PeriodAmount * Agreement."Rebate %" / 100);
        exit(0);
    end;
}

codeunit 50151 "Rebate Mgt."
{
    procedure GetStrategy(CalcType: Enum "Rebate Calculation Type") Strategy: Interface "Rebate Calculation Strategy"
    begin
        case CalcType of
            CalcType::"Volume Based":
                exit(Codeunit::"Volume Based Rebate");
            CalcType::Tiered:
                exit(Codeunit::"Tiered Rebate");
        end;
    end;
}
```

The point of the exercise: adding a third strategy later should mean *one new codeunit and one new enum value* — zero changes to `Rebate Mgt.` beyond the case line, and ideally you replace even that with a lookup so it's truly open for extension.

### 6.2 Integration event pattern (landed cost allocation)

```al
codeunit 50152 "Landed Cost Mgt."
{
    [IntegrationEvent(false, false)]
    local procedure OnBeforeAllocateLandedCost(var PurchHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    procedure AllocateLandedCost(var PurchHeader: Record "Purchase Header")
    var
        IsHandled: Boolean;
    begin
        OnBeforeAllocateLandedCost(PurchHeader, IsHandled);
        if IsHandled then
            exit;

        // default allocation logic by value or weight, via the interface above
    end;
}

codeunit 50153 "Landed Cost Event Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure OnAfterPostPurchaseDoc(var PurchHeader: Record "Purchase Header")
    var
        LandedCostMgt: Codeunit "Landed Cost Mgt.";
    begin
        LandedCostMgt.AllocateLandedCost(PurchHeader);
    end;
}
```

Publishing your own `OnBeforeAllocateLandedCost` event even though nothing subscribes to it yet is the actual exercise — it's what makes your codeunit extensible by someone else without editing it.

### 6.3 Modern error handling (quality hold)

```al
procedure CheckQualityStatus(ItemLedgerEntryNo: Integer)
var
    ILE: Record "Item Ledger Entry";
    ErrorInfo: ErrorInfo;
begin
    ILE.Get(ItemLedgerEntryNo);
    if ILE."Quality Status" = ILE."Quality Status"::Failed then begin
        ErrorInfo.Message := StrSubstNo('Lot %1 failed quality inspection and cannot be consumed.', ILE."Lot No.");
        ErrorInfo.AddAction('Open inspection', Codeunit::"Quality Inspection Mgt.", 'OpenInspection');
        Error(ErrorInfo);
    end;
end;
```

Compare this to a bare `Error('Lot failed inspection.')` — the difference is the user gets a button that takes them somewhere useful instead of a dead end.

### 6.4 Permission set as an AL object

```al
permissionset 50198 "MG Purchase Rebate Admin"
{
    Assignable = true;
    Caption = 'MarginGuard - Purchase Rebate Admin';

    Permissions =
        tabledata "Vendor Rebate Agreement" = RIMD,
        tabledata "Vendor Rebate Ledger Entry" = RIMD,
        page "Vendor Rebate Agreement List" = X;
}
```

---

## 7. Testing strategy

Don't bolt this on at the end — write the first test codeunit as soon as `Landed Cost Mgt.` exists, so the habit is in place before the codebase gets big.

- Use the standard `Library - Purchase`, `Library - Sales`, `Library - Manufacturing`, and `Library - ERM` helper codeunits to build test data instead of hand-rolling records.
- Tag test codeunits with `Subtype = Test` and give every test method the `[Test]` attribute.
- Structure each test as Given/When/Then in comments even if AL doesn't enforce it — it keeps intent readable six months later.

Example shape:

```al
codeunit 50900 "MG Landed Cost Tests"
{
    Subtype = Test;

    [Test]
    procedure AllocatesLandedCostByValue()
    var
        PurchHeader: Record "Purchase Header";
        LibraryPurchase: Codeunit "Library - Purchase";
        LandedCostMgt: Codeunit "Landed Cost Mgt.";
    begin
        // Given a posted purchase invoice with two lines of different value
        // ... build test data via LibraryPurchase ...

        // When landed cost is allocated by value
        LandedCostMgt.AllocateLandedCost(PurchHeader);

        // Then each line's allocated share is proportional to its line amount
        // ... assert ...
    end;
}
```

Minimum coverage to aim for before calling a phase "done": one happy-path test and one boundary/error-path test per public procedure that contains real logic (not simple getters/setters).

---

## 8. Performance & AL Guidelines checklist

Run through this before you consider any phase finished — these are the things CodeCop/PerTestCop and a good PR reviewer would flag:

- [ ] No `FINDSET` on a large table without `SetLoadFields` first.
- [ ] No hardcoded G/L account numbers, percentages, or thresholds — everything comes from the setup table.
- [ ] No business logic inside a page's trigger that belongs in a codeunit.
- [ ] Temp tables/records used for any multi-step calculation staging (e.g. the allocation loop), not repeated table writes.
- [ ] Every publicly-callable procedure that does real work has an integration event around it (before or after) if it's plausible a partner would want to extend it.
- [ ] Every enum is `Extensible = true` unless you have a specific reason not to.
- [ ] Dimensions are copied, never dropped, on every journal line you create.
- [ ] Labels use `Label` variables (with a comment for translators), not raw strings, anywhere user-facing.

---

## 9. Stretch goals

Once the core is solid:

- Wire variance approval into the real **Workflow** feature instead of a simple status enum.
- Write an **upgrade codeunit** that migrates data when you deliberately change a table's schema (e.g. splitting `Vendor Rebate Agreement` into header/line).
- Add **XLIFF** translation files and actually run the app in a second language.
- Expose the profitability query through the **API** and pull it into a Power BI report.
- Add **telemetry** dimensions rich enough that you could answer "which vendor's rebate calculations are slowest" from Application Insights alone.

---

## 10. Definition of done

You're done with MarginGuard, not just "done coding," when:

- A partner could add a third rebate strategy and a third margin policy without editing any of your existing codeunits.
- Every blocking error a user can hit has an `ErrorInfo` action that gets them closer to fixing it.
- Every module's test codeunit passes clean, and at least one test per module deliberately exercises the cross-module dependency (e.g. a variance from Manufacturing actually changing the margin calculation in Sales).
- The profitability cockpit shows a number that changes visibly when you post a rebate, a variance, and a sales order — proof the modules are actually wired together, not just sitting side by side.
