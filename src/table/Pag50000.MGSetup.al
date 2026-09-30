page 50000 "MG Setup"
{
    ApplicationArea = All;
    Caption = 'MG Setup';
    PageType = Card;
    SourceTable = "MG Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Allow Pending Lots"; Rec."Allow Pending Lots")
                {
                    ToolTip = 'Specifies the value of the Allow Pending Lots field.', Comment = '%';
                }
                field("Block on Release"; Rec."Block on Release")
                {
                    ToolTip = 'Specifies the value of the Block on Release field.', Comment = '%';
                }
                field("Enable Telemetry"; Rec."Enable Telemetry")
                {
                    ToolTip = 'Specifies the value of the Enable Telemetry field.', Comment = '%';
                }
                field("Include Variance Trend"; Rec."Include Variance Trend")
                {
                    ToolTip = 'Specifies the value of the Include Variance Trend field.', Comment = '%';
                }
                field("Inspection Nos."; Rec."Inspection Nos.")
                {
                    ToolTip = 'Specifies the value of the Inspection Nos. field.', Comment = '%';
                }
                field("Loyalty Period (DateFormula)"; Rec."Loyalty Period (DateFormula)")
                {
                    ToolTip = 'Specifies the value of the Loyalty Period (DateFormula) field.', Comment = '%';
                }
                field("Margin Threshold %"; Rec."Margin Threshold %")
                {
                    ToolTip = 'Specifies the value of the Margin Threshold % field.', Comment = '%';
                }
                field("Rebate Accrual Nos."; Rec."Rebate Accrual Nos.")
                {
                    ToolTip = 'Specifies the value of the Rebate Accrual Nos. field.', Comment = '%';
                }
                field("Rebate Income Acc., "; Rec."Rebate Income Acc., ")
                {
                    ToolTip = 'Specifies the value of the Rebate Income Acc., field.', Comment = '%';
                }
                field("Rebate Receivable Acc."; Rec."Rebate Receivable Acc.")
                {
                    ToolTip = 'Specifies the value of the Rebate Receivable Acc. field.', Comment = '%';
                }
                field("Rebate Source Code"; Rec."Rebate Source Code")
                {
                    ToolTip = 'Specifies the value of the Rebate Source Code field.', Comment = '%';
                }
                field(SIngleton; Rec.SIngleton)
                {
                    ToolTip = 'Specifies the value of the SIngleton field.', Comment = '%';
                }
                field("Strategic Allowance %"; Rec."Strategic Allowance %")
                {
                    ToolTip = 'Specifies the value of the Strategic Allowance % field.', Comment = '%';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.', Comment = '%';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.', Comment = '%';
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field.', Comment = '%';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.', Comment = '%';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.', Comment = '%';
                }
                field("Variance Trend Days"; Rec."Variance Trend Days")
                {
                    ToolTip = 'Specifies the value of the Variance Trend Days field.', Comment = '%';
                }
                field("Warning Band %"; Rec."Warning Band %")
                {
                    ToolTip = 'Specifies the value of the Warning Band % field.', Comment = '%';
                }
            }
        }
    }
}
