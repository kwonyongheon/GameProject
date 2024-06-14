using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Enemy : MonoBehaviour
{
    public Transform target;
    public int maxHealth = 100; // 최대 체력
    private int currentHealth; // 현재 체력

    private BoxCollider boxCollider; // 박스 콜라이더 컴포넌트
    private NavMeshAgent nav; // 네비게이션 메쉬 에이전트 컴포넌트

    private void Awake()
    {
        boxCollider = GetComponent<BoxCollider>();
        nav = GetComponent<NavMeshAgent>();
        currentHealth = maxHealth; // 초기 체력 설정
    }

    private void Update()
    {
        nav.SetDestination(target.position); // 목표 위치로 이동
    }

    // 데미지를 받는 함수
    public void TakeDamage(int damage)
    {
        currentHealth -= damage;
        if (currentHealth <= 0)
        {
            Die();
        }
    }

    // 적 사망 처리
    private void Die()
    {
        gameObject.SetActive(false); // 적 비활성화
        FindObjectOfType<GameManager>().CheckMonsters(); // GameManager에게 알림
    }
}
