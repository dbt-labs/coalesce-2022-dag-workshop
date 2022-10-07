{#
    Exercise: Create two macros that, in conjunction, check if a given model node
    has dependency Nodes with a maturity level within the `warning_maturity_levels`.
    In the TODOs below, there will be opportunities to identify the dependencies for
    a particular model Node of interest, introspect into the `graph` object to reference
    specific Nodes, and leverage Node metadata to log messages to the command line.

    Useful links:
    - `graph` Object: https://docs.getdbt.com/reference/dbt-jinja-functions/graph
    - Node Object: https://schemas.getdbt.com/dbt/manifest/v6/index.html#tab-pane_nodes_additionalProperties_oneOf_i2
    - The `log()` function: https://schemas.getdbt.com/dbt/manifest/v6/index.html#tab-pane_nodes_additionalProperties_oneOf_i2
#}

{% macro ref_maturity_warning(current_model, warning_maturity_levels) %}

    {# We can only access graph object during execution. #}
    {% if not execute %}
        {{ return() }}
    {% endif %}


    {# Create a model list to store any low-maturity models #}
    {% set immature_model_list = [] %}

    {# Now, grab the graph node for this reference#}
    {% for node in get_model_dependency_nodes(current_model) %}

        {# Check the maturity! If it's "low", then add it to the model_list #}
        {% if node.config.meta.maturity in warning_maturity_levels %}
            {% do immature_model_list.append(node.name) %}
        {% endif %}

    {% endfor %}

    {# If there are items in model_list, then raise a warning. #}
    {% if immature_model_list | length > 0 %}
        {{ log(
            "WARNING: The " ~ current_model.name ~ " model references immature models. " ~
            "Immature models: " ~ ', '.join(immature_model_list),
            info=True
        ) }}
    {% endif %}

{% endmacro %}


{% macro get_model_dependency_nodes(current_model) %}

    {% set dependencies = [] %}

    {% for reference_unique_id in current_model.depends_on.nodes %}

        {# Now, grab the graph node for this reference#}
        {% if reference_unique_id in graph.nodes %}
            {% do dependencies.append(graph.nodes[reference_unique_id]) %}
        {% endif %}

    {% endfor %}

    {{ return(dependencies) }}

{% endmacro %}
