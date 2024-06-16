using System.Collections;
using UnityEngine;
using UnityEngine.AI;

public class Boss : MonoBehaviour
{
    public GameObject fireballPrefab;
    public GameObject iceballPrefab;
    public GameObject slowballPrefab;
    public Transform firePoint;
    public int maxHealth = 1000;
    public int currentHealth; // 현재 체력을 저장하는 변수
    public GameObject player;
    private Player playerScript;
    public float moveSpeed = 3f;
    private NavMeshAgent navAgent;
    public GameObject deathReplacementPrefab; // 보스가 죽었을 때 교체할 Prefab
    private GameObject currentPrefabInstance; // 현재 Prefab 인스턴스

    enum AttackType { Fireball, Iceball, Slowball } // 공격 유형

    void Start()
    {
        currentHealth = maxHealth; // 초기 체력 설정
        player = GameObject.FindWithTag("Player");
        if (player != null)
        {
            playerScript = player.GetComponent<Player>();
            navAgent = GetComponent<NavMeshAgent>();
            if (playerScript != null && navAgent != null)
            {
                StartCoroutine(BossAttackRoutine());
                Debug.Log("보스 공격 루틴 시작.");
            }
            else
            {
                Debug.LogError("플레이어 스크립트 또는 NavMeshAgent를 찾을 수 없습니다.");
            }
        }
        else
        {
            Debug.LogError("플레이어 오브젝트가 할당되지 않았습니다.");
        }
    }

    void Update()
    {
        if (playerScript != null && playerScript.currentHealth > 0 && currentHealth > 0)
        {
            FollowPlayer(); // 플레이어 추적 함수 호출
        }
    }

    void FollowPlayer()
    {
        if (navAgent != null && player != null)
        {
            navAgent.SetDestination(player.transform.position); // 플레이어 위치로 이동
        }
    }

    IEnumerator BossAttackRoutine()
    {
        while (currentHealth > 0 && playerScript.currentHealth > 0)
        {
            yield return new WaitForSeconds(5f);
            AttackType attack = (AttackType)Random.Range(0, 3);
            Debug.Log("선택된 공격: " + attack);

            switch (attack)
            {
                case AttackType.Fireball:
                    StartCoroutine(ShootProjectile(fireballPrefab, BossAttack.ProjectileType.Fireball));
                    break;
                case AttackType.Iceball:
                    StartCoroutine(ShootProjectile(iceballPrefab, BossAttack.ProjectileType.Iceball));
                    break;
                case AttackType.Slowball:
                    StartCoroutine(ShootProjectile(slowballPrefab, BossAttack.ProjectileType.Slowball));
                    break;
            }
        }

        Debug.Log("보스 또는 플레이어가 죽었습니다. 공격 루틴을 중지합니다.");
    }

    IEnumerator ShootProjectile(GameObject prefab, BossAttack.ProjectileType type)
    {
        for (int i = 0; i < 3; i++)
        {
            GameObject projectile = Instantiate(prefab, firePoint.position, firePoint.rotation);
            Rigidbody rb = projectile.GetComponent<Rigidbody>();
            if (rb != null)
            {
                rb.velocity = (player.transform.position - firePoint.position).normalized * 10f;
            }
            else
            {
                Debug.LogError("발사체 프리팹에서 Rigidbody를 찾을 수 없습니다.");
            }

            BossAttack bossAttack = projectile.GetComponent<BossAttack>();
            if (bossAttack != null)
            {
                bossAttack.projectileType = type;
            }
            else
            {
                Debug.LogError("발사체 프리팹에서 BossAttack 스크립트를 찾을 수 없습니다.");
            }

            yield return new WaitForSeconds(0.5f);
        }
    }

    public void TakeDamage(int damage)
    {
        currentHealth -= damage; // 현재 체력 감소
        Debug.Log("보스가 피해를 입었습니다. 현재 체력: " + currentHealth);
        if (currentHealth <= 0)
        {
            Die();
        }
    }

    // 보스 사망 처리
    private void Die()
    {
        gameObject.SetActive(false); // 보스 비활성화
        FindObjectOfType<GameManager>().CheckMonsters(); // GameManager에게 알림

        // 현재 위치에 deathReplacementPrefab을 인스턴스화
        if (deathReplacementPrefab != null)
        {
            currentPrefabInstance = Instantiate(deathReplacementPrefab, transform.position, transform.rotation);
        }
        else
        {
            Debug.LogError("deathReplacementPrefab이 할당되지 않았습니다!");
        }

        // gameObject가 활성화되어 있는지 확인하고 코루틴을 시작
        if (gameObject != null && gameObject.activeInHierarchy)
        {
            StartCoroutine(DestroyAfterDelay(0.5f)); // 0.5초 후에 파괴 처리
        }
        else
        {
            Debug.LogError("게임 오브젝트가 비활성화되어 있거나 null입니다. 코루틴을 시작할 수 없습니다.");
        }
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

        // gameObject가 유효한지 확인 후 파괴
        if (gameObject != null)
        {
            Destroy(gameObject); // 현재 GameObject 파괴
        }
        else
        {
            Debug.LogError("게임 오브젝트가 이미 null이기 때문에 파괴할 수 없습니다.");
        }
    }
}
