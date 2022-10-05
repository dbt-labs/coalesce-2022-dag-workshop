{% macro ref_maturity_warning(current_model, warning_maturity_levels) %}

    {# We can only access graph object during execution. #}
    {% if not execute %}
        {{ return() }}
    {% endif %}


    {# Create a model list to store any low-maturity models #}
    {% set immature_model_list = [] %}

    {# Now, grab the graph node for this reference #}


    {% for node in get_model_dependency_nodes(current_model) %}

        {#
            TODO: For each Node returned by get_model_dependency_nodes,
            check if the maturity of the node stored in the nodes meta field.
            If the value is contained within the `warning_maturity_levels`
            list, then add the node name to the immature_model_list.
        #}

    {% endfor %}

    {#
        TODO: If there are values in the `immature_model_list`, then
        log a message that warns the user that there have been references
        to immature models.
    #}


{% endmacro %}


{% macro get_model_dependency_nodes(current_model) %}

    {% set dependencies = [] %}

    {#
        TODO: For each unique_id stored in the model's node dependency list,
        `current_model.depends_on.nodes`, grab the related Node from the graph
        and add it to the `dependencies`list.
    #}
    {{ return(dependencies) }}
{% endmacro %}