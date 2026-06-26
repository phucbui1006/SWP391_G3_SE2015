package model;

public class CategorySpecTemplate {
    private int templateId;
    private int categoryId;
    private String specName;
    private String specType;
    private String allowedValues;
    private boolean isRequired;
    private int displayOrder;

    public CategorySpecTemplate() {
    }

    public CategorySpecTemplate(int templateId, int categoryId, String specName, String specType, String allowedValues, boolean isRequired, int displayOrder) {
        this.templateId = templateId;
        this.categoryId = categoryId;
        this.specName = specName;
        this.specType = specType;
        this.allowedValues = allowedValues;
        this.isRequired = isRequired;
        this.displayOrder = displayOrder;
    }

    public int getTemplateId() {
        return templateId;
    }

    public void setTemplateId(int templateId) {
        this.templateId = templateId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getSpecName() {
        return specName;
    }

    public void setSpecName(String specName) {
        this.specName = specName;
    }

    public String getSpecType() {
        return specType;
    }

    public void setSpecType(String specType) {
        this.specType = specType;
    }

    public String getAllowedValues() {
        return allowedValues;
    }

    public void setAllowedValues(String allowedValues) {
        this.allowedValues = allowedValues;
    }

    public boolean isRequired() {
        return isRequired;
    }

    public void setRequired(boolean isRequired) {
        this.isRequired = isRequired;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    private String specValue;

    public String getSpecValue() {
        return specValue;
    }

    public void setSpecValue(String specValue) {
        this.specValue = specValue;
    }
}
