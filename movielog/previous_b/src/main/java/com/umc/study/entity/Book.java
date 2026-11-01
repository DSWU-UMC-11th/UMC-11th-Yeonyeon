
package com.umc.study.entity;
import jakarta.persistence.*;

import com.umc.study.entity.Category;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.Locale;

@Entity
@Table(name = "book")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="book_id")
    private Long bookId;

    @ManyToOne(fetch = FetchType.LAZY) //책 여러 권: 카테고리 하나
    //LAZY 의미: 책 조회할 때 카테고리를 바로 안 가져오고 실제로 접근할 떄 가져옴
    @JoinColumn(name="category_id",nullable=false)
    private Category category;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name="is_available",nullable = false)
    private Boolean isAvailable=true;

    public Book(Category category,String title, String description){
        this.category=category;
        this.title=title;
        this.description=description;
    }
}

