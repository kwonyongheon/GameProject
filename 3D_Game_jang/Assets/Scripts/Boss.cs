using System.Collections;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.UI; // UI 네임스페이스 추가

public class Boss : MonoBehaviour
{
    public Transform target;
    public int maxHealth = 100; // 최대 체력
    private int currentHealth; // 현재 체력

    public GameObject deathReplacementPrefab; // 적이 죽었을 때 교체할 Prefab
    private GameObject currentPrefabInstance; // 현재 Prefab 인스턴스

    private BoxCollider boxCollider; // 박스 콜라이더 컴포넌트
    private NavMeshAgent nav; // 네비게이션 메쉬 에이전트 컴포넌트

    public Slider healthSlider;

    private void Awake()
    {
        boxCollider = GetComponent<BoxCollider>();
        nav = GetComponent<NavMeshAgent>();
        currentHealth = maxHealth; // 초기 체력 설정

        UpdateHealthUI(); // 초기 UI 업데이트
    }

    private void Update()
    {
        nav.SetDestination(target.position); // 목표 위치로 이동
    }

    // 데미지를 받는 함수
    public void TakeDamage(int damage)
    {
        currentHealth -= damage;
        UpdateHealthUI(); // 체력 감소 후 UI 업데이트

        if (currentHealth <= 0)
        {
            Die();
        }
    }

    private void Die()
    {
        // 적 사망 처리 로직
        UpdateHealthUI(); // UI 업데이트
    }

    // 일정 시간 후에 Prefab 인스턴스를 파괴하는 코루틴
    private IEnumerator DestroyAfterDelay(float delay)
    {
        yield return new WaitForSeconds(delay);

        // 현재 Prefab 인스턴스를 파괴
        if (currentPrefabInstance != null)
        {
            Destroy(currentPrefabInstance);
        }

        Destroy(gameObject); // 현재 GameObject 파괴
    }

    private void UpdateHealthUI()
    {
        healthSlider.value = (float)currentHealth / maxHealth; // 체력 슬라이더 업데이트 (백분율)
    }
}
