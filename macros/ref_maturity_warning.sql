{% macro ref_maturity_warning(warning_maturity_levels) %}

    {# We can only access the model and graph objects during execution. #}
    {% if execute %}

        {% do log('===== Checking for Immature Model References ======', info=True) %}

        {# Introspect to get the current model's dependencies. #}
        {% for current_model in get_models_from_graph() %}

            {# Create a model list to store any low-maturity models #}
            {% set immature_model_list = [] %}
            {% set dependencies = get_model_dependency_nodes(current_model) %}

            {# Now, grab the graph node for this reference#}
            {% for node in dependencies %}

                {# Check the maturity! If it's "low", then add it to the model_list #}
                {% set maturity = node.config.meta.maturity %}
                {% if maturity in warning_maturity_levels %}
                    {% do immature_model_list.append(node.name) %}
                {% endif %}

            {% endfor %}

            {# If there are items in model_list, then raise a warning. #}
            {% if immature_model_list | length > 0 %}
                {% do exceptions.warn(
                    "WARNING: The " ~ current_model.name ~ " model references " ~  immature_model_list | length
                    ~ " models with a low maturity. Models: " ~ ', '.join(immature_model_list)
                ) %}
            {% endif %}

        {% endfor %}

        {% do log('===== Immature Model Reference Check Complete =====', info=True) %}

    {% endif %}

{% endmacro %}


{% macro get_models_from_graph() %}
    {% set models = graph.nodes.values()
        | selectattr("resource_type", "equalto", 'model')%}
    {{ return(models) }}
{% endmacro %}


{% macro get_model_dependency_nodes(current_model) %}

    {% set dependencies = [] %}

    {%- set references = current_model.depends_on.nodes -%}

    {% for reference_unique_id in references %}

        {# If we're not referencing a model, then continue. #}
        {% if not reference_unique_id.startswith('model') %}
            {% do continue %}
        {% endif %}

        {# Now, grab the graph node for this reference#}
        {% for node in graph.nodes.values()
            | selectattr("unique_id", "equalto", reference_unique_id) %}

            {% do dependencies.append(node) %}

        {% endfor %}

    {% endfor %}
    {{ return(dependencies) }}

{% endmacro %}
