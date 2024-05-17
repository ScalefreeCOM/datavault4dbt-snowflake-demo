{% macro hub_macro(business_key, hashkey_name, source_model, record_source) %}

WITH source_data AS (

    SELECT
        MD5({{ business_key }}) as {{ hashkey_name }},
        {{ business_key }},
        GETDATE() as load_date,
        '{{ record_source }}' as record_source
    FROM {{ ref(source_model) }} 

)

SELECT 
    *
FROM source_data sd

{% if is_incremental() %}
WHERE NOT EXISTS 
    (SELECT 1 FROM {{ this }} t WHERE sd.{{ hashkey_name }} = t.{{ hashkey_name }})
{% endif %}

{% endmacro %}