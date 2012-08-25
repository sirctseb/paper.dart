#library("MapList.dart");

/** MapList is a collection whose members can be accessed as
 * a List or as Map
 **/

// TODO Map and List interface implementations
class MapList<E> implements Collection<E> {
  List _list;
  Map _map;
  
  E operator[](key) {
    if(key is num) return _list[key];
    return _map[key];
  }
  operator[]=(key, value) {
    if(key is num) _list[key] = value;
    else _map[key] = value; 
  }
  
  /** Collection interface **/
  bool every(bool f(E element) ) {
    return _list.every(f) && _map.getValues().every(f);
  }
  
  Collection<E> filter(bool f(E element)) {
    List result = [];
    _list.filter(f).forEach((e) => result.add(e));
    _map.getValues().filter(f).forEach((e) => result.add(e));
  }
  
  void forEach(void f(E element)) {
    _list.forEach(f);
    _map.getValues().forEach(f);
  }
  
  bool isEmpty() {
    return _list.isEmpty() && _map.isEmpty();
  }
  
  int length() {
    return _list.length + _map.length;
  }
  
  Collection map(f(E element)) {
    List result = [];
    _list.map(f).forEach((e) => result.add(e));
    _map.getValues().map(f).forEach((e) => result.add(e));
  }
  
  reduce(initialValue, combine(previousValue, E element)) {
    _map.getValues().reduce(_list.reduce(initialValue, combine), combine);
  }
  
  bool some(bool f(E element)) {
    return _list.some(f) || _map.getValues().some(f);
  }
}
