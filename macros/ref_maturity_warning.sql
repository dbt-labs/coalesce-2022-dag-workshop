{% macro ref_maturity_warning(warning_maturity_levels) %}

    {# Create a model list to store any low-maturity models #}
    {% set model_list = [] %}

    {# We can only access the model and graph objects during execution. #}
    {% if execute %}

        {# Introspect to get the current model's dependencies. #}
        {%- set references = model.depends_on.nodes -%}

        {# Iterate each reference #}
        {% for reference_unique_id in references %}

            {# If we're not referencing a model, then continue. #}
            {% if not reference_unique_id.startswith('model') %}
                {% do continue %}
            {% endif %}

            {# Now, grab the graph node for this reference#}
            {% for node in graph.nodes.values()
                | selectattr("unique_id", "equalto", reference_unique_id) %}

                {# Check the maturity! If it's "low", then add it to the model_list #}
                {% set maturity = node.config.meta.maturity %}
                {% if maturity in warning_maturity_levels %}
                    {% do model_list.append(node.name) %}
                {% endif %}

            {% endfor %}

        {% endfor %}

        {# If there are items in model_list, then raise a warning. #}
        {% if model_list | length > 0 %}
            {% do exceptions.warn(
                "WARNING: The " ~ model.name ~ " model references " ~  model_list | length
                ~ " models with a low maturity. Models: " ~ ', '.join(model_list)) %}
        {% endif %}

    {% endif %}

{% endmacro %}