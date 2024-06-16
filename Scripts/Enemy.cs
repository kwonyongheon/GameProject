using System.Collections;
using UnityEngine;
using UnityEngine.AI;

public class Enemy : MonoBehaviour
{
    public Transform target;
    public int maxHealth = 100; // 최대 체력
    public int currentHealth; // 현재 체력
    public bool isBoss; // 보스 여부

    public GameObject deathReplacementPrefab; // 적이 죽었을 때 교체할 Prefab
    private GameObject currentPrefabInstance; // 현재 Prefab 인스턴스

    public CapsuleCollider capsuleCollider; // 캡슐 콜라이더 컴포넌트
    public NavMeshAgent nav; // 네비게이션 메쉬 에이전트 컴포넌트

    public AudioClip deathSound; // 죽을 때 재생할 소리
    private AudioSource audioSource;

    void Awake()
    {
        capsuleCollider = GetComponent<CapsuleCollider>();
        nav = GetComponent<NavMeshAgent>();
        currentHealth = maxHealth; // 초기 체력 설정
        audioSource = GetComponent<AudioSource>();
        if (audioSource == null)
        {
            audioSource = gameObject.AddComponent<AudioSource>();
        }
    }

    void Update()
    {
        if (target != null && nav != null && nav.enabled && gameObject.activeSelf && !isBoss) // 보스가 아닐 때만 이동
        {
            nav.SetDestination(target.position); // 목표 위치로 이동
        }
    }

    // 초기화 메서드
    public void Initialize()
    {
        currentHealth = maxHealth;
        if (nav != null && !isBoss)
        {
            nav.enabled = true; // NavMeshAgent 다시 활성화
        }
    }

    // 데미지를 받는 함수
    public void TakeDamage(int damage)
    {
        currentHealth -= damage;
        if (currentHealth <= 0)
        {
            StartCoroutine(Die());
        }
    }

    // 적 사망 처리
    private IEnumerator Die()
    {
        Debug.Log("적이 죽어갑니다.");

        if (deathSound != null && audioSource != null)
        {
            audioSource.PlayOneShot(deathSound);
        }

        // 소리 재생이 끝날 때까지 대기
        yield return new WaitWhile(() => audioSource.isPlaying);

        gameObject.SetActive(false); // 적 비활성화

        // 점수 추가
        GameManager.Instance.AddScore(10);

        // GameManager에게 알림
        FindObjectOfType<GameManager>().CheckMonsters();

        // 현재 위치에 deathReplacementPrefab을 인스턴스화
        if (deathReplacementPrefab != null)
        {
            currentPrefabInstance = Instantiate(deathReplacementPrefab, transform.position, transform.rotation);
            Debug.Log("deathReplacementPrefab을 위치에 인스턴스화: " + transform.position);
        }
        else
        {
            Debug.LogError("deathReplacementPrefab이 할당되지 않았습니다!");
        }

        // 1초 대기 후 Prefab 인스턴스를 파괴
        yield return new WaitForSeconds(1.0f);

        if (currentPrefabInstance != null)
        {
            Destroy(currentPrefabInstance);
            Debug.Log("deathReplacementPrefab 인스턴스를 파괴했습니다.");
        }

        // gameObject가 유효한지 확인 후 파괴
        if (gameObject != null)
        {
            Destroy(gameObject); // 현재 GameObject 파괴
            Debug.Log("적 게임 오브젝트를 파괴했습니다.");
        }
        else
        {
            Debug.LogError("게임 오브젝트가 이미 null이기 때문에 파괴할 수 없습니다.");
        }
    }
}
