package com.umc.backend.service;

import com.umc.backend.dto.LoginRequest;
import com.umc.backend.dto.LoginResponse;
import com.umc.backend.entity.Member;
import com.umc.backend.exception.ApiException;
import com.umc.backend.repository.MemberRepository;
import com.umc.backend.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public LoginResponse login(LoginRequest request) {
        Member member = memberRepository.findByEmail(request.email())
                .orElseThrow(this::invalidCredentials);
        if (!passwordEncoder.matches(request.password(), member.getPassword())) {
            throw invalidCredentials();
        }
        return new LoginResponse(member.getNickname(),
                jwtUtil.createAccessToken(member.getMemberId(), member.getEmail()));
    }

    private ApiException invalidCredentials() {
        return new ApiException(HttpStatus.UNAUTHORIZED, "AUTH401_1",
                "이메일 또는 비밀번호가 올바르지 않습니다.");
    }
}
