package com.umc.study.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity //이 클래스가 DB테이블과 연결된다는 의미
@Table(name="category")  //연결할 테이블 이름
@Getter //lombok이 getter를 자동 생성
@NoArgsConstructor(access= AccessLevel.PROTECTED)  //JPA가 객체를 만들려면 기본 생성자가 필요함. protected로 해서 아무데서나 new Book()하는 걸 막음
public class Category {
    @Id //해당 필드가 PK라는 걸 알림
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    //PK를 DB의 AUTO_INCREMENT에 맡김 (저장할 때 id를 직접 안넣음)
    @Column(name="category_id") //필드 categoryId를 컬럼 category_id에 연결. nullable=false는 NOT NULL, length는 VARCHAR 길이
    private Long categoryId;

    @Column(nullable=false, length=50)
    private String name;

}
