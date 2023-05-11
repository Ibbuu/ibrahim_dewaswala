def get_value(obj, path):
    keys = path.split('/')
    if len(keys) == 0:
        return obj
    key = keys[0]
    if type(obj) == list or type(obj) == tuple:
        for v in obj:
            if key in v:
                if len(keys) > 1:
                    return get_value(v[key], '/'.join(keys[1:]))
                else:
                    return v[key]
    elif type(obj) == dict:
        if key in obj:
            if len(keys) > 1:
                return get_value(obj[key], '/'.join(keys[1:]))
            else:
                return obj[key]
        else:
            return None
    else:
        if obj == key:
            return obj
        else:
            return None

nested_object = {
    'a': {
        'b': {
            'c': [{"d":[8]},{"f":"l"}]
        }
    }
}

path = 'a/b/c/d'
value = get_value(nested_object, path)
print(value)