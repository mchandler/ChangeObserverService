public class AdVic_ChangeObserverService {

    public static final List<String> TYPE_EXCEPTIONS = new List<String>{'ADDRESS'};
    public static List<String> FIELD_EXCEPTIONS = new List<String>{'createddate', 'createdbyid'};

    /**
     * For use on an SObject's BEFORE UPDATE trigger. This service observes changes
     * on an object during the before update trigger and writes a list of all
     * changed fields to a field specified in the hiddenFieldName argument.
     * <p>
     * AdVic_ChangeObserverService.trackChanges(Trigger.new, Trigger.oldMap, 'Changed_Fields_List__c');
     *
     * @param triggerNew An instance of the Trigger.new collection
     * @param triggerOldMap An instance of the Trigger.oldMap collection
     * @param hiddenFieldName The name of the field on the target object to write the names of the changed fields
     */
    public static void trackChanges(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap, String hiddenFieldName) {
        DescribeSObjectResult d = triggerNew.get(0).getSObjectType().getDescribe();

        for (SObject sObj : triggerNew) {
            observeChanges(sObj, triggerOldMap.get(sObj.Id), hiddenFieldName, d.fields.getMap());
        }
    }

    private static void observeChanges(SObject newObject, SObject oldObject, String hiddenFieldName, Map<String, SObjectField> fieldMap) {
        Set<String> allFields = fieldMap.keySet();
        String currentChangedFields = (String) newObject.get(hiddenFieldName);
        Set<String> currentChanges = String.isNotBlank(currentChangedFields) ? new Set<String>(currentChangedFields.split(';')) : new Set<String>();

        // We don't care about the field that tracks changes, so let's add it to the field exception list
        FIELD_EXCEPTIONS.add(hiddenFieldName);

        for (String field : allFields) {
            if (TYPE_EXCEPTIONS.contains(fieldMap.get(field).getDescribe().getType().name())) {
                // if we don't care about this type, then let's move on
                continue;
            }

            if (FIELD_EXCEPTIONS.contains(field)) {
                // if we don't care about this field, then let's move on
                continue;
            }

            if (field.trim().length() > 0 && newObject.get(field) != oldObject.get(field)) {
                currentChanges.add(field);
            }
        }

        // update this object instance's hidden field with all changed fields
        if (currentChanges.size() > 0) {
            newObject.put(hiddenFieldName, String.join(new List<String>(currentChanges), ';'));
        }
    }

}