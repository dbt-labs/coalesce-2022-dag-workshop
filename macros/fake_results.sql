{% macro fake_results(count = 10) %}
    {% set results = [ ] %}
    {% for node in graph.nodes.values()  %}
        {% if node.resource_type in ('model', 'test') and results|length < count %}
            {% do results.append({
                'status': 'success',
                'execution_time': 1.1,
                'thread_id': 'Thread-1',
                'timing': [],
                'adapter_response': {
                    'rows_affected': 1,
                },
                'message': 'Faked Result',
                'node': node
            }) %}
        {% endif %}

    {% endfor %}
    {{ return(results) }}
{% endmacro %}