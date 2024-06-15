using System.Collections;
using UnityEngine;
using UnityEngine.AI;

public class Enemy : MonoBehaviour
{
    public Transform target;
    public int maxHealth = 100; // 최대 체력
    private int currentHealth; // 현재 체력

    public GameObject deathReplacementPrefab; // 적이 죽었을 때 교체할 Prefab
    private GameObject currentPrefabInstance; // 현재 Prefab 인스턴스

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
        // 현재 위치에 deathReplacementPrefab을 인스턴스화
        currentPrefabInstance = Instantiate(deathReplacementPrefab, transform.position, transform.rotation);

        StartCoroutine(DestroyAfterDelay(0.5f)); // 0.5초 후에 파괴 처리
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
}
