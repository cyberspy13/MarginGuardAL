table 50000 "MG Setup"
{
    Caption = 'MG Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; SIngleton; Code[10])
        {
            Caption = 'SIngleton';
        }
        field(2; "Margin Threshold %"; Decimal)
        {
            Caption = 'Margin Threshold %';
        }
        field(3; "Warning Band %"; Decimal)
        {
            Caption = 'Warning Band %';
        }
        field(4; "Strategic Allowance %"; Decimal)
        {
            Caption = 'Strategic Allowance %';
        }
        field(5; "Block on Release"; Decimal)
        {
            Caption = 'Block on Release';
        }
        field(6; "Include Variance Trend"; Text[50])
        {
            Caption = 'Include Variance Trend';
        }
        field(7; "Variance Trend Days"; Date)
        {
            Caption = 'Variance Trend Days';
        }
        field(8; "Allow Pending Lots"; Text[100])
        {
            Caption = 'Allow Pending Lots';
        }
        field(9; "Inspection Nos."; Code[20])
        {
            Caption = 'Inspection Nos.';
        }
        field(10; "Rebate Accrual Nos."; Code[10])
        {
            Caption = 'Rebate Accrual Nos.';
        }
        field(11; "Rebate Receivable Acc."; Code[10])
        {
            Caption = 'Rebate Receivable Acc.';
        }
        field(12; "Rebate Income Acc., "; Code[10])
        {
            Caption = 'Rebate Income Acc., ';
        }
        field(13; "Rebate Source Code"; Code[10])
        {
            Caption = 'Rebate Source Code';
        }
        field(14; "Loyalty Period (DateFormula)"; Code[10])
        {
            Caption = 'Loyalty Period (DateFormula)';
        }
        field(15; "Enable Telemetry"; Code[10])
        {
            Caption = 'Enable Telemetry';
        }
    }
    keys
    {
        key(PK; SIngleton)
        {
            Clustered = true;
        }
    }
}
