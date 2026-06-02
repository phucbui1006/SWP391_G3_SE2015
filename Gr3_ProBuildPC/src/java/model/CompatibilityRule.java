package model;

public class CompatibilityRule {
    private int ruleId;
    private int sourceCategoryId;
    private int targetCategoryId;
    private String sourceSpecName;
    private String targetSpecName;
    private String comparisonOperator;

    public CompatibilityRule() {
    }

    public CompatibilityRule(int ruleId, int sourceCategoryId, int targetCategoryId,
                             String sourceSpecName, String targetSpecName, String comparisonOperator) {
        this.ruleId = ruleId;
        this.sourceCategoryId = sourceCategoryId;
        this.targetCategoryId = targetCategoryId;
        this.sourceSpecName = sourceSpecName;
        this.targetSpecName = targetSpecName;
        this.comparisonOperator = comparisonOperator;
    }

    public int getRuleId() {
        return ruleId;
    }

    public void setRuleId(int ruleId) {
        this.ruleId = ruleId;
    }

    public int getSourceCategoryId() {
        return sourceCategoryId;
    }

    public void setSourceCategoryId(int sourceCategoryId) {
        this.sourceCategoryId = sourceCategoryId;
    }

    public int getTargetCategoryId() {
        return targetCategoryId;
    }

    public void setTargetCategoryId(int targetCategoryId) {
        this.targetCategoryId = targetCategoryId;
    }

    public String getSourceSpecName() {
        return sourceSpecName;
    }

    public void setSourceSpecName(String sourceSpecName) {
        this.sourceSpecName = sourceSpecName;
    }

    public String getTargetSpecName() {
        return targetSpecName;
    }

    public void setTargetSpecName(String targetSpecName) {
        this.targetSpecName = targetSpecName;
    }

    public String getComparisonOperator() {
        return comparisonOperator;
    }

    public void setComparisonOperator(String comparisonOperator) {
        this.comparisonOperator = comparisonOperator;
    }
}