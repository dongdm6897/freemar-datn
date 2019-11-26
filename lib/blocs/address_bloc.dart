import 'dart:async';

import 'package:flutter_rentaza/blocs/bloc_provider.dart';
import 'package:flutter_rentaza/models/Address/district.dart';
import 'package:flutter_rentaza/models/Address/province.dart';
import 'package:flutter_rentaza/models/Address/street.dart';
import 'package:flutter_rentaza/models/Address/ward.dart';
import 'package:flutter_rentaza/providers/repository.dart';
import 'package:rxdart/rxdart.dart';

class AddressBloc implements BlocBase {
  final _repository = Repository();

  /// Province
  PublishSubject<List<Province>> _provinceController =
      PublishSubject<List<Province>>();

  Stream<List<Province>> get streamProvince => _provinceController.stream;

  Sink<List<Province>> get provinceSink => _provinceController.sink;

  /// District
  PublishSubject<List<District>> _districtController =
      PublishSubject<List<District>>();

  Stream<List<District>> get streamDistrict => _districtController.stream;

  Sink<List<District>> get districtSink => _districtController.sink;

  /// Ward
  PublishSubject<List<Ward>> _wardController = PublishSubject<List<Ward>>();

  Stream<List<Ward>> get streamWard => _wardController.stream;

  Sink<List<Ward>> get wardSink => _wardController.sink;

  /// Street
  PublishSubject<List<Street>> _streetController =
      PublishSubject<List<Street>>();

  Stream<List<Street>> get streamStreet => _streetController.stream;

  Sink<List<Street>> get streetSink => _streetController.sink;

  /// Load
  PublishSubject<bool> _loadController = PublishSubject<bool>();

  Stream<bool> get streamLoad => _loadController.stream;

  Sink<bool> get loadSink => _loadController.sink;

  AddressBloc() {
    loadSink.add(true);
    _repository.getProvince().then((values) {
      if (!_provinceController.isClosed) {
        provinceSink.add(values);
        loadSink.add(false);
      }
    });
  }

  Future<bool> loadDistrict(int provinceId) async {
    Map params = Map();
    params['province_id'] = provinceId;
    loadSink.add(true);
    return await _repository.getDistrict(params).then((values) {
      if (!_districtController.isClosed) {
        districtSink.add(values);
        loadSink.add(false);
        return true;
      }
      return false;
    });
  }

  Future<bool> loadWard(int districtId, int provinceId) async {
    Map params = Map();
    params['province_id'] = provinceId;
    params['district_id'] = districtId;
    loadSink.add(true);
    return await _repository.getWard(params).then((values) {
      if (!_wardController.isClosed) {
        wardSink.add(values);
        loadSink.add(false);
        return true;
      }
      return false;
    });
  }

  loadStreet(int districtId, int provinceId) {
    Map params = Map();
    params['province_id'] = provinceId;
    params['district_id'] = districtId;
    loadSink.add(true);
    _repository.getStreet(params).then((values) {
      if (!_streetController.isClosed) {
        streetSink.add(values);
        loadSink.add(false);
      }
    });
  }

  @override
  void dispose() {
    _loadController.close();
    _provinceController.close();
    _streetController.close();
    _districtController.close();
    _wardController.close();
  }
}
