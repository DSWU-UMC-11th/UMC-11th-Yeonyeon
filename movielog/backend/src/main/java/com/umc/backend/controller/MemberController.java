package com.umc.backend.controller;

import com.umc.backend.dto.EmailCheckResponse;
import com.umc.backend.dto.NicknameCheckResponse;
import com.umc.backend.service.MemberService;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/members")
public class MemberController {

    private final MemberService memberService;

    // 선택 미션: 닉네임 2~12자 검증. 위반 시 available 판단 전에 400 응답
    @GetMapping("/nickname/{nickname}")
    public NicknameCheckResponse checkNickname(
            @PathVariable @Size(min = 2, max = 12, message = "닉네임은 2~12자여야 합니다.") String nickname) {
        return memberService.checkNickname(nickname);
    }

    // 선택 미션: 이메일 형식 검증. 위반 시 400 응답
    @GetMapping("/email/{email}")
    public EmailCheckResponse checkEmail(
            @PathVariable @Email(message = "이메일 형식이 올바르지 않습니다.") String email) {
        return memberService.checkEmail(email);
    }
}
