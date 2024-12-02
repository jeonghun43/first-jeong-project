import 'package:dimo/screen/homescreen.dart';
import 'package:dimo/data/db.dart';
import 'package:dimo/data/memo.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  var _contacts;
  bool settingBool = false;
  DbHelper dbh = DbHelper();

  _onIntroEnd(context) async {
    if (settingBool) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("onboarding", true);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      Fluttertoast.showToast(msg: "설정을 완료해주세요");
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      onDone: () => _onIntroEnd(context),
      showBackButton: true,
      done: Text("Done"),
      back: Icon(Icons.navigate_before),
      next: Text("next"),
      pages: [
        PageViewModel(
            decoration: pageDeco(),
            title: "디모 : 디지털 메모",
            body:
                "사소한 것 하나까지 기억해준다면\n아마 감동받을걸요?\n\n기억력이 좋지 않더라도\n 디모와 함께라면 가능합니다!",
            image: Image.asset("assets/img_1.png")),
        PageViewModel(
          decoration: pageDeco(),
          title: "간단한 사용",
          body: "간단한 메모 기능으로\n기억해줄 수 있어요\n\n 터치 한 번으로 기억력 UP",
          image: Image.asset("assets/img_2.png"),
        ),
        PageViewModel(
          decoration: pageDeco(),
          title: "디모와 함께",
          body: "자주 까먹나요? 괜찮습니다!\n기억력에 대한 부정적인 감정은 버리고 \n중요한 일에 더욱 집중해보세요",
          image: Image.asset("assets/img_3.png"),
        ),
        PageViewModel(
          decoration: pageDeco(),
          image: Image.asset("assets/gift.png"),
          title: "디모라는 선물",
          bodyWidget: Column(
            children: [
              settingBool == true
                  ? Text(
                      "설정 상태 : 세팅 완료",
                      style: TextStyle(
                          fontSize: 23,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    )
                  : Text(
                      "설정 상태 : 세팅 필요",
                      style: TextStyle(
                          fontSize: 19, color: Colors.black.withOpacity(0.7)),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "설정을 진행해보세요",
                    style: TextStyle(fontSize: 19),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      startSetting();
                    },
                    child: Text("설정하기"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future startSetting() async {
    var status = await Permission.contacts.status; //연락처 접근 가능 여부 status에 담아주기
    await Permission.contacts.request();
    print("request 실행했덤"); //우선 reqest 날려줬음

    if (status.isGranted) {
      // 접근 가능하다면 "허락됨" 출력
      print("허락됨");
    } else if (status.isDenied) {
      //그렇지 않다면 "거부됨"출력하고 권한 요청
      print("거부됨");
      await Permission.contacts.request();
      print("요청을 보냈음");
    }

    if (status.isPermanentlyDenied) {
      //앱 설정에서 꺼놓은경우 요청
      openAppSettings();
    }

    List<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);
    _contacts = contacts;

    initInsertData();

    setState(() {
      settingBool = true;
    });
  }

  Future initInsertData() async {
    bool hasNoData;
    String name;
    await dbh.deleteAllMemo(); //일단은 테스트를 위해 데이터 싹 다 밀고 다시 시작했음
    int size = await dbh.dbSize();
    if (size == 0) {
      size = _contacts.length;
      for (int i = 0; i < size; i++) {
        name = _contacts[i].displayName;
        hasNoData = !(await dbh
            .isthereMemo(name)); //데이터베이스에 그 값이 들어가있는지 아닌지 확인후 추가할지 말지를 판단함
        if (hasNoData) {
          await dbh.insertMemo(Memo(name: name, content: "", pin: 0));
        }
      }
    }
  }

  PageDecoration pageDeco() {
    PageDecoration pd = PageDecoration(
        titleTextStyle: TextStyle(
            fontSize: 21, fontWeight: FontWeight.bold, color: Colors.black),
        bodyTextStyle: TextStyle(
          fontSize: 18,
          color: Colors.black.withOpacity(0.6),
        ),
        imagePadding: EdgeInsets.only(top: 50));

    return pd;
  }
}
