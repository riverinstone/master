<%@page import="org.apache.commons.mail.EmailAttachment"%>

<%@page import="org.apache.commons.mail.MultiPartEmail"%>

<%@page import="java.io.File"%>

<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>

<%@page import="com.oreilly.servlet.MultipartRequest"%>

<%@ page language="java" contentType="text/html; charset=UTF-8"

pageEncoding="UTF-8"%>

<%

//(1) 업로드 작업

// 1 request

 

// 2 upload 폴더 만들고 물리적 경로

//ServletContext application = request.getServletContext(); => 이미존재

String realPath = application.getRealPath("/temp");

System.out.println("realPath : " + realPath);

 

// 3 파일업로드 최대크기 제한값

int maxPostSize = 1024 * 1024 * 10; // 1024byte * 1024 * 10; (업로드 10MB 제한)

 

// 4 한글처리 유니코드로 설정 "utf-8"

 

// 5 업로드하는 파일명이 기존 업로드된 파일명과 같은 경우 => 파일명 자동변경 정책

 

// 파일업로드 처리 완료!

MultipartRequest multi

= new MultipartRequest(request,

realPath,

maxPostSize,

"utf-8",

new DefaultFileRenamePolicy());

// 업로드한 파일이름 가져오기

String fileName = multi.getFilesystemName("fileName");

 

File file = new File(realPath, fileName);

System.out.println("파일 경로: " + file.getAbsolutePath()); // 파일의 절대경로

 

// (2) 파일첨부 이메일 전송 작업

// 첨부파일 객체준비

EmailAttachment attachment = new EmailAttachment();

attachment.setPath(realPath+"/"+fileName);

attachment.setDescription("파일에 대한 설명");

attachment.setName(fileName); // 첨부파일 이름 => 필수사항은 아님

 

MultiPartEmail multiPartEmail = new MultiPartEmail();

 

// 파라미터 가져오기

String receiver = multi.getParameter("receiver");

String subject = multi.getParameter("subject");

String content = multi.getParameter("content");

 

long beginTime = System.currentTimeMillis();// 시작시간 설정

 

// SMTP 서버 연결 설정

// SMTP 서버를 daum으로 했기 때문에 daum 계정으로 접속

multiPartEmail.setHostName("smtp.daum.net");

multiPartEmail.setSmtpPort(465); // 465(SSL방식) or 587(TLS방식)

multiPartEmail.setAuthentication("id", "password"); // 아이디,패스워드

multiPartEmail.setSSLOnConnect(true); // SSL 접속 활성화

multiPartEmail.setStartTLSEnabled(true); // TLS 접속 활성화

 

// 보내는 사람=> daum으로 SMTP 서버로 연결했기 때문에 보내는 메일도 daum이 되어야한다

multiPartEmail.setFrom("whdgus4501@daum.net","테스터","UTF-8");

// 받는 사람

multiPartEmail.addTo(receiver,"받는 사람","UTF-8");

 

 

// 이메일에 추가될 내용 설정

multiPartEmail.setSubject(subject); //제목

multiPartEmail.setMsg(content);

multiPartEmail.attach(attachment); // 첨부파일 추가

 

 

//* 지연시간을 줄이기 위한 방법으로 스레드로 이메일 전송

new Thread(new Runnable() {

@Override

public void run() {

try{

multiPartEmail.send();

long execTime = System.currentTimeMillis() - beginTime;

System.out.println("이메일 전송에 걸린시간: "+execTime);

}catch(Exception e){}

}

}).start();

%>

<script>

alert('메일이 전송되었습니다.');

history.back();

</script>