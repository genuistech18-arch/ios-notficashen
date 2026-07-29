# 📖 دليل تكامل إرسال الإشعارات (Notification Integration Guide)

هذا الملف مخصص لمطور الباك إند الآخر (Backend Developer) ليشرح له كيفية التكامل وإرسال الإشعارات الفورية إلى هواتف أولياء الأمور والطلاب من خلال نظامنا.

---

## 🚀 تفاصيل رابط الاتصال (API Endpoint)

لإرسال إشعار، يجب إرسال طلب من نوع **POST** إلى الرابط التالي:

```text
POST https://fatherpadge.onrender.com/api/v1/notifications/send
```

---

## 🔑 ترويسات الطلب (Headers Required)

يجب تضمين الترويسات التالية في كل طلب:

| المفتاح (Key) | القيمة (Value) | الوصف |
| :--- | :--- | :--- |
| `Content-Type` | `application/json` | نوع محتوى الطلب |
| `x-api-key` | `bbba7e39d3dac12715ff733e38def2943af88132460c35ca82db0762ee0e839b` | مفتاح الحماية والتحقق الخاص بك لتفويض الإرسال |

> [!NOTE]  
> يمكنك تغيير مفتاح التحقق `x-api-key` في أي وقت من إعدادات البيئة (Environment Variables) على موقع Render عبر المتغير `API_SEND_KEY`.

---

## 📦 محتوى الطلب (Request Body JSON)

يتم إرسال البيانات بصيغة JSON كالتالي:

```json
{
  "code": "7495",
  "message": "نص رسالة الإشعار التي ستظهر على شاشة الهاتف"
}
```

### المتغيرات المطلوبة:
* **`code`** (نص / String): كود الطالب المستهدف (مثل الكود المكتوب في التطبيق للتحقق من الطالب).
* **`message`** (نص / String): نص الرسالة التي تريد إيصالها لولي الأمر أو الطالب لتظهر كإشعار خارجي.

---

## 📥 ردود السيرفر المتوقعة (API Responses)

### 1. في حال النجاح (201 Created):
```json
{
  "status": "sent"
}
```
*تعني أن الإشعار تم إرساله بنجاح ووصل لجهاز المستخدم.*

### 2. في حال عدم وجود رمز جهاز للمستخدم (201 Created):
```json
{
  "status": "no_token"
}
```
*تعني أن الكود صحيح وتم حفظ الإشعار في قاعدة البيانات، ولكن المستخدم لم يفتح التطبيق بعد على هاتفه لربط جهازه.*

### 3. في حال الكود غير مسجل نهائياً (201 Created):
```json
{
  "status": "not_found"
}
```
*تعني أن كود الطالب المدخل غير موجود بقاعدة البيانات.*

### 4. في حال عدم تطابق مفتاح الحماية (401 Unauthorized):
```json
{
  "message": "Invalid or missing API key",
  "error": "Unauthorized",
  "statusCode": 401
}
```

---

## 💻 أمثلة برمجية للتكامل (Code Integration Examples)

### 1. مثال باستخدام JavaScript / Node.js (Axios)
```javascript
const axios = require('axios');

async function sendNotification(studentCode, textMessage) {
  try {
    const response = await axios.post('https://fatherpadge.onrender.com/api/v1/notifications/send', {
      code: studentCode,
      message: textMessage
    }, {
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': 'bbba7e39d3dac12715ff733e38def2943af88132460c35ca82db0762ee0e839b'
      }
    });
    console.log('FCM Notification Result:', response.data);
  } catch (error) {
    console.error('Error sending notification:', error.response ? error.response.data : error.message);
  }
}

// تشغيل التجربة
sendNotification('7495', 'مرحباً بك! تم تسجيل حضور الطالب اليوم بنجاح.');
```

### 2. مثال باستخدام Python (Requests)
```python
import requests

def send_notification(student_code, text_message):
    url = "https://fatherpadge.onrender.com/api/v1/notifications/send"
    headers = {
        "Content-Type": "application/json",
        "x-api-key": "bbba7e39d3dac12715ff733e38def2943af88132460c35ca82db0762ee0e839b"
    }
    payload = {
        "code": student_code,
        "message": text_message
    }
    
    try:
        response = requests.post(url, json=payload, headers=headers)
        print("Response status:", response.status_code)
        print("Response data:", response.json())
    except Exception as e:
        print("Error:", e)

# تشغيل التجربة
send_notification("7495", "مرحباً بك! تم تسجيل حضور الطالب اليوم بنجاح.")
```

### 3. مثال باستخدام PHP (cURL)
```php
<?php

function sendNotification($studentCode, $textMessage) {
    $url = "https://fatherpadge.onrender.com/api/v1/notifications/send";
    $apiKey = "bbba7e39d3dac12715ff733e38def2943af88132460c35ca82db0762ee0e839b";

    $data = array(
        "code" => $studentCode,
        "message" => $textMessage
    );
    $payload = json_encode($data);

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array(
        'Content-Type: application/json',
        'x-api-key: ' . $apiKey
    ));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    
    $result = curl_exec($ch);
    curl_close($ch);

    return json_decode($result, true);
}

// تشغيل التجربة
$response = sendNotification("7495", "مرحباً بك! تم تسجيل حضور الطالب اليوم بنجاح.");
print_r($response);
?>
```
