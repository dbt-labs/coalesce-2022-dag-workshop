{% macro ref_maturity_warning(warning_maturity_levels) %}

    {# We can only access the model and graph objects during execution. #}
    {% if execute %}

        {% do log('===== Checking for Immature Model References ======', info=True) %}

        {# Introspect to get the current model's dependencies. #}
        {% for current_model in graph.nodes.values() %}

            {# Create a model list to store any low-maturity models #}
            {% set model_list = [] %}

            {% if current_model.resource_type == 'model' %}
                {%- set references = current_model.depends_on.nodes -%}

                {# Move into a separate macro! #}

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
                        "WARNING: The " ~ current_model.name ~ " model references " ~  model_list | length
                        ~ " models with a low maturity. Models: " ~ ', '.join(model_list)) %}
                {% endif %}
            {% endif %}


        {% endfor %}

        {% do log('===== Immature Model Reference Check Complete =====', info=True) %}

    {% endif %}

{% endmacro %}
