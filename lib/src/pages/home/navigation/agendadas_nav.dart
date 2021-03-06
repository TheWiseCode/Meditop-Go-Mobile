import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meditop_go/src/services/auth.dart';
import 'package:meditop_go/src/services/dio.dart';
import 'package:provider/provider.dart';

class AgendadasNav extends StatefulWidget {
  @override
  _AgendadasNavState createState() => _AgendadasNavState();
}

class _AgendadasNavState extends State<AgendadasNav> {
  List? _agendadas;

  @override
  void initState() {
    super.initState();
    loadAgendadas();
  }

  Future<void> loadAgendadas() async {
    String? token = Provider.of<Auth>(context, listen: false).token;
    Response response = await http().get('/get-scheduled',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    setState(() {
      try {
        _agendadas = response.data;
      } catch (e) {
        _agendadas = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //loadAgendadas();
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: _agendadas == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _actualizarData(context),
              child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Consultas agendadas',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      _agendadas!.length == 0
                          ? Center(child: Text('No tiene consultas agendadas'))
                          : listAgendadas(context),
                    ],
                  )),
            ),
    ));
  }

  Widget listAgendadas(BuildContext context) {
    return ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemCount: this._agendadas!.length,
        itemBuilder: (BuildContext context, int index) {
          String id = _agendadas![index]['id_consult'].toString();
          String url = _agendadas![index]['url_jitsi'];
          String doctor = _agendadas![index]['name_doctor'];
          String specialty = _agendadas![index]['name_specialty'];
          String timeConsult = _agendadas![index]['time'].toString();
          DateFormat df = DateFormat('yyyy-MM-dd HH:mm:ss');
          DateTime dt = df.parse(timeConsult);
          String fecha = DateFormat('dd/MM/yyyy').format(dt);
          String hora = DateFormat('HH:mm:ss').format(dt);
          return Column(
            children: [
              const SizedBox(height: 5),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.medical_services),
                      trailing: RaisedButton(
                          onPressed: () => _inRoom(context, _agendadas![index]),
                          child: Text('Entrar')),
                      title: Text('Especialidad: $specialty'),
                      subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Doctor: $doctor'),
                            Text('Fecha: $fecha'),
                            Text('Hora: $hora'),
                          ]),
                    ),
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('Detalles'),
                          onPressed: () {
                            /*Navigator.of(context).pushNamed("/order",
                                arguments: _agendadas[index]['id']);*/
                          },
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),*/
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          );
        });
  }

  _actualizarData(BuildContext context) async {
    String? token = Provider.of<Auth>(context, listen: false).token;
    Response response = await http().get('/get-scheduled',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    setState(() {
      _agendadas = response.data;
    });
  }

  _inRoom(BuildContext context, Map datos) async {
    int id = datos['id_consult'];
    print(datos);
    String? token = Provider.of<Auth>(context, listen: false).token;
    Map data = {'id_consult': id};
    Response response = await http().post('/consult-in',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    if (response.statusCode == 200) {
      print(response.data['message']);
      String link = datos['url_jitsi'];
      Navigator.of(context).pushNamed("/consult", arguments: link);
    } else {
      print(response.data['message']);
      dialog(context, response.data['message']);
      //Navigator.of(context).pushNamed("/meet");
    }
  }

  void dialog(BuildContext context, String mensaje) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text("Mensaje Consulta"),
          content: new Text(mensaje),
          actions: [
            // ignore: deprecated_member_use
            FlatButton(
              child: Text('Cerrar!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ));
  }
}
