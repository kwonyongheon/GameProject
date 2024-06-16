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
    public int currentHealth; // ���� ü���� �����ϴ� ����
    public GameObject player;
    private Player playerScript;
    public float moveSpeed = 3f;
    private NavMeshAgent navAgent;
    public GameObject deathReplacementPrefab; // ������ �׾��� �� ��ü�� Prefab
    private GameObject currentPrefabInstance; // ���� Prefab �ν��Ͻ�

    enum AttackType { Fireball, Iceball, Slowball } // ���� ����

    void Start()
    {
        currentHealth = maxHealth; // �ʱ� ü�� ����
        player = GameObject.FindWithTag("Player");
        if (player != null)
        {
            playerScript = player.GetComponent<Player>();
            navAgent = GetComponent<NavMeshAgent>();
            if (playerScript != null && navAgent != null)
            {
                StartCoroutine(BossAttackRoutine());
                Debug.Log("���� ���� ��ƾ ����.");
            }
            else
            {
                Debug.LogError("�÷��̾� ��ũ��Ʈ �Ǵ� NavMeshAgent�� ã�� �� �����ϴ�.");
            }
        }
        else
        {
            Debug.LogError("�÷��̾� ������Ʈ�� �Ҵ���� �ʾҽ��ϴ�.");
        }
    }

    void Update()
    {
        if (playerScript != null && playerScript.currentHealth > 0 && currentHealth > 0)
        {
            FollowPlayer(); // �÷��̾� ���� �Լ� ȣ��
        }
    }

    void FollowPlayer()
    {
        if (navAgent != null && player != null)
        {
            navAgent.SetDestination(player.transform.position); // �÷��̾� ��ġ�� �̵�
        }
    }

    IEnumerator BossAttackRoutine()
    {
        while (currentHealth > 0 && playerScript.currentHealth > 0)
        {
            yield return new WaitForSeconds(5f);
            AttackType attack = (AttackType)Random.Range(0, 3);
            Debug.Log("���õ� ����: " + attack);

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

        Debug.Log("���� �Ǵ� �÷��̾ �׾����ϴ�. ���� ��ƾ�� �����մϴ�.");
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
                Debug.LogError("�߻�ü �����տ��� Rigidbody�� ã�� �� �����ϴ�.");
            }

            BossAttack bossAttack = projectile.GetComponent<BossAttack>();
            if (bossAttack != null)
            {
                bossAttack.projectileType = type;
            }
            else
            {
                Debug.LogError("�߻�ü �����տ��� BossAttack ��ũ��Ʈ�� ã�� �� �����ϴ�.");
            }

            yield return new WaitForSeconds(0.5f);
        }
    }

    public void TakeDamage(int damage)
    {
        currentHealth -= damage; // ���� ü�� ����
        Debug.Log("������ ���ظ� �Ծ����ϴ�. ���� ü��: " + currentHealth);
        if (currentHealth <= 0)
        {
            Die();
        }
    }

    // ���� ��� ó��
    private void Die()
    {
        gameObject.SetActive(false); // ���� ��Ȱ��ȭ
        FindObjectOfType<GameManager>().CheckMonsters(); // GameManager���� �˸�

        // ���� ��ġ�� deathReplacementPrefab�� �ν��Ͻ�ȭ
        if (deathReplacementPrefab != null)
        {
            currentPrefabInstance = Instantiate(deathReplacementPrefab, transform.position, transform.rotation);
        }
        else
        {
            Debug.LogError("deathReplacementPrefab�� �Ҵ���� �ʾҽ��ϴ�!");
        }

        // gameObject�� Ȱ��ȭ�Ǿ� �ִ��� Ȯ���ϰ� �ڷ�ƾ�� ����
        if (gameObject != null && gameObject.activeInHierarchy)
        {
            StartCoroutine(DestroyAfterDelay(0.5f)); // 0.5�� �Ŀ� �ı� ó��
        }
        else
        {
            Debug.LogError("���� ������Ʈ�� ��Ȱ��ȭ�Ǿ� �ְų� null�Դϴ�. �ڷ�ƾ�� ������ �� �����ϴ�.");
        }
    }

    // ���� �ð� �Ŀ� Prefab �ν��Ͻ��� �ı��ϴ� �ڷ�ƾ
    private IEnumerator DestroyAfterDelay(float delay)
    {
        yield return new WaitForSeconds(delay);

        // ���� Prefab �ν��Ͻ��� �ı�
        if (currentPrefabInstance != null)
        {
            Destroy(currentPrefabInstance);
        }

        // gameObject�� ��ȿ���� Ȯ�� �� �ı�
        if (gameObject != null)
        {
            Destroy(gameObject); // ���� GameObject �ı�
        }
        else
        {
            Debug.LogError("���� ������Ʈ�� �̹� null�̱� ������ �ı��� �� �����ϴ�.");
        }
    }
}
