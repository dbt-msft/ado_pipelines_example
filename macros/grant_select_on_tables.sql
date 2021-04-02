-- macros/grant_select_on_tables.sql

{% macro grant_select_on_tables(webgroups, table) %}
{% if target.schema == 'prd' %}
    {% for webgroup in webgroups %}
      IF NOT EXISTS (
        SELECT [name]
        FROM   sys.database_principals
        WHERE  [name] =  '{{ webgroup }}'
      )
        CREATE USER [{{ webgroup }}] FROM EXTERNAL PROVIDER 
      GRANT SELECT
        ON {{ table.include(database=false) }} TO [{{ webgroup }}]
    {% endfor %}
{% else %}
select 1; -- hooks will error if they don't have valid SQL in them, this handles that!
{% endif %}
{% endmacro %}
