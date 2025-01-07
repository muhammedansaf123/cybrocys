import 'package:flutter/material.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class Containertile extends StatelessWidget {
  final IconData icons;
  final Color color;
  final String title;
  final double value;
  final String daylength;
  final bool isdown;
  final String percentage;
  const Containertile(
      {super.key,
      this.isdown = false,
      required this.percentage,
      required this.icons,
      required this.color,
      required this.daylength,
      required this.title,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Icon(icons)),
              SizedBox(
                width: 5,
              ),
              Text(
                title,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            value.toString(),
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Row(
            children: [
              Text(daylength),
              Spacer(),
              isdown
                  ? RotationTransition(
                      turns: AlwaysStoppedAnimation(0 / 360),
                      child: Image.asset(
                        'assets/up.png',
                        scale: 5,
                      ),
                    )
                  : RotationTransition(
                      turns: AlwaysStoppedAnimation(90 / 360),
                      child: Image.asset(
                        'assets/up.png',
                        scale: 6,
                      ),
                    ),
              Text(percentage)
            ],
          )
        ],
      ),
    );
  }
}

class Doctorcharts extends StatelessWidget {
  const Doctorcharts({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData('Surgeries', 25, Colors.deepPurple),
      ChartData('Consultation', 38, Colors.blue),
      ChartData('pending', 34, Colors.orangeAccent),
      ChartData('Done', 52, Colors.green)
    ];
    return Center(
        child: Container(
            child: SfCircularChart(series: <CircularSeries>[
      PieSeries<ChartData, String>(
        dataSource: chartData,
        dataLabelMapper: (datum, index) => '${datum.percentage.toString()} %',
        pointColorMapper: (ChartData data, _) => data.color,
        xValueMapper: (ChartData data, _) => data.name,
        yValueMapper: (ChartData data, _) => data.percentage,
        explode: true,
        dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(color: Colors.white, fontSize: 15)),
      )
    ])));
  }
}

class ChartData {
  ChartData(this.name, this.percentage, [this.color]);
  final String name;
  final double percentage;
  final Color? color;
}

class PaymentChart extends StatelessWidget {
  const PaymentChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            child: SfCartesianChart(
                legend: Legend(isVisible: true),
                primaryYAxis: NumericAxis(
                    //Formatting the labels in locale’s currency pattern with symbol.
                    numberFormat:
                        NumberFormat.currency(locale: 'en_In', symbol: "\$")),
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
          LineSeries<Paymentdata, String>(
            dataSource: [
              Paymentdata('Jan', 35),
              Paymentdata('Feb', 28),
              Paymentdata('Mar', 34),
              Paymentdata('Apr', 32),
              Paymentdata('May', 40)
            ],
            dataLabelSettings: DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(color: Colors.black, fontSize: 15)),
            xValueMapper: (Paymentdata data, _) => data.x,
            yValueMapper: (Paymentdata data, _) => data.y,
          )
        ])));
  }
}

class Paymentdata {
  Paymentdata(this.x, this.y);
  final String x;
  final double? y;
}

class managerchart extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  managerchart({Key? key}) : super(key: key);

  @override
  managerchartState createState() => managerchartState();
}

class managerchartState extends State<managerchart> {
  late List<ManagerData> data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    data = [
      ManagerData('MON', 12),
      ManagerData('TUE', 15),
      ManagerData('WED', 30),
      ManagerData('THU', 6.4),
      ManagerData('FRI', 14)
    ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
        tooltipBehavior: _tooltip,
        series: <CartesianSeries<ManagerData, String>>[
          ColumnSeries<ManagerData, String>(
              dataSource: data,
              xValueMapper: (ManagerData data, _) => data.x,
              yValueMapper: (ManagerData data, _) => data.y,
              name: 'Gold',
              color: Color.fromRGBO(8, 142, 255, 1))
        ]);
  }
}

class ManagerData {
  ManagerData(this.x, this.y);

  final String x;
  final double y;
}

class ActivityGraph extends StatelessWidget {
  const ActivityGraph({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ActivityData> doctorData = [
      ActivityData('SU', 3),
      ActivityData('MO', 1),
      ActivityData('TU', 5),
      ActivityData('WE', 3),
      ActivityData('TH', 7),
      ActivityData('FR', 4),
      ActivityData('SA', 5),
    ];

    final List<ActivityData> patientData = [
      ActivityData('SU', 2),
      ActivityData('MO', 5),
      ActivityData('TU', 4),
      ActivityData('WE', 2),
      ActivityData('TH', 6),
      ActivityData('FR', 1),
      ActivityData('SA', 7),
    ];

    return SfCartesianChart(
      title: ChartTitle(text: 'Activity cycle'),
      backgroundColor: Colors.grey[200],
      legend: Legend(isVisible: true),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        SplineSeries<ActivityData, String>(
          name: 'Doctors',
          dataSource: doctorData,
          splineType: SplineType.cardinal,
          cardinalSplineTension: 0.9,
          color: Colors.red,
          xValueMapper: (ActivityData data, _) => data.x,
          yValueMapper: (ActivityData data, _) => data.y,
        ),
        SplineSeries<ActivityData, String>(
          name: 'Patients',
          dataSource: patientData,
          splineType: SplineType.cardinal,
          cardinalSplineTension: 0.9,
          color: Colors.blue,
          xValueMapper: (ActivityData data, _) => data.x,
          yValueMapper: (ActivityData data, _) => data.y,
        ),
      ],
    );
  }
}

class ActivityData {
  ActivityData(this.x, this.y);
  final String x;
  final double y;
}

class DoctorsNumbertile extends StatelessWidget {
  final String title;

  final String value;
  const DoctorsNumbertile(
      {super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: Colors.deepPurple),
      child: Row(
        children: [
          SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Spacer(),
          SizedBox(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  height: 2,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }
}

class LabResultsTile extends StatelessWidget {
  final IconData icons;
  final Color color;
  final String title;
  final String count;
  final Color progresscolor;
  final bool isdown;
  final double percentage;
  final Color iconcolor;
  const LabResultsTile(
      {super.key,
      required this.progresscolor,
      this.isdown = false,
      required this.iconcolor,
      required this.percentage,
      required this.icons,
      required this.color,
      required this.title,
      required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 170,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 10.0,
            percent: percentage,
            header: Row(
              children: [
                Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: iconcolor,
                    ),
                    child: Icon(icons)),
                SizedBox(
                  width: 5,
                ),
                Text(
                  title,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            center: Text(count),
            backgroundColor: Colors.grey,
            progressColor: progresscolor,
          ),
        ],
      ),
    );
  }
}

class Customrow extends StatelessWidget {
  final IconData icons;
  final void Function()? onTap;
  final String title;

  const Customrow(
      {super.key,
      required this.icons,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.withOpacity(0.7),
        child: Icon(
          icons,
          color: Colors.white,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      trailing: Icon(Icons.arrow_forward_ios_outlined),
    );
  }
}

class Customcontainer extends StatelessWidget {
  final Widget widget;
  const Customcontainer({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
        child: widget);
  }
}

class Mybutton extends StatelessWidget {
  final bool load;
  final String text;
  final void Function()? onPressed;
  const Mybutton(
      {super.key,
      required this.load,
      required this.onPressed,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      width: 360,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.deepPurple)),
              onPressed: onPressed,
              child: load
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      text,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
        ),
      ),
    );
  }
}


class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
