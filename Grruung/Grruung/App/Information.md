# Information

## Team Link
1. 깃헙: https://github.com/APP-iOS7/Grruung
2. 피그마: https://www.figma.com/design/2PrLejdYYyspmALbnWztxr/%ED%8C%8C%EC%9D%B4%EB%84%90%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-5%EC%A1%B0?node-id=0-1&p=f&t=1t9JMogP0EMO9g0J-0
3. 구글시트: https://docs.google.com/spreadsheets/d/1oBD2LaOn7yf7pe0oTgWwo7MMDYhnt019kRC603otRcg/edit?usp=share_link
4. 파이어베이스: https://console.firebase.google.com/project/grruung
5. 노션: https://www.notion.so/likelion/5-1e344860a4f480708c19df2827bcbc04?pvs=4

## Reference Link
1. 무료 캐릭터 에셋: https://itch.io/game-assets/free/tag-characters 


## Commit Convention
1. feat/기능이름 으로 브랜치 생성 (예. feat/basics)

## Model Convention
1. 구조체 이름 앞에 GR 붙이기 (예. GRUser) 
2. Firebase에 저장할 때 컬렉션 타입(collection("컬렉션이름"))의 컬렉션이름은 복수형으로 표현 (예. db.collection("users").document(authResult.user.uid)))
3. 구조체, 클래스, 열거형은 기본적으로 단수형으로 표현. 
4. 실제로 값이 여러개가 들어가는 변수는 복수형으로 표현 (예. 배열타입 characters: [사자, 쿼카, 염소]) 
   (목적: ForEach 구문을 쓸 때 혼동 방지. "ForEach(characters, id: \.self) { character in" 라는 식으로 쓰기 위해) 
                    

## Code Convention
1. 들여쓰기 통일하기 4칸

## 설치해야할 패키지
### Firebase
1. FirebaseAnalytics
2. FirebaseAuth
3. FirebaseDatabase
4. FirebaseFirestore
5. FirebaseVertexAI
6. FirebaseAppCheck
