import 'package:mongo_pool/src/feature/connection_feature_model.dart';

abstract class Observable {
  ///  Constructor
  Observable([List<Observer>? observers]) {
    _observers = observers ?? [];
  }

  ///  List of observers
  List<Observer>? _observers;

  ///  Register an observer
  void subscribe(Observer observer) {
    _observers?.add(observer);
  }

  ///  Unregister an observer
  void unsubscribe(Observer observer) {
    _observers?.remove(observer);
  }

  ///  Notify all observers
  void notifyExpire(ConnectionInfo connectionInfo) {
    _observers?.forEach(
      (observer) => observer.expiredConnectionNotifier(connectionInfo),
    );
  }
}

class Observer {
  Observer();

  void expiredConnectionNotifier(ConnectionInfo connectionInfo) {
    print('Expired connection: $connectionInfo');
  }
}
