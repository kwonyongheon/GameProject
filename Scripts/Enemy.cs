using System.Collections;
using UnityEngine;
using UnityEngine.AI;

public class Enemy : MonoBehaviour
{
    public Transform target;
    public int maxHealth = 100; // �ִ� ü��
    public int currentHealth; // ���� ü��
    public bool isBoss; // ���� ����

    public GameObject deathReplacementPrefab; // ���� �׾��� �� ��ü�� Prefab
    private GameObject currentPrefabInstance; // ���� Prefab �ν��Ͻ�

    public CapsuleCollider capsuleCollider; // ĸ�� �ݶ��̴� ������Ʈ
    public NavMeshAgent nav; // �׺���̼� �޽� ������Ʈ ������Ʈ

    public AudioClip deathSound; // ���� �� ����� �Ҹ�
    private AudioSource audioSource;

    void Awake()
    {
        capsuleCollider = GetComponent<CapsuleCollider>();
        nav = GetComponent<NavMeshAgent>();
        currentHealth = maxHealth; // �ʱ� ü�� ����
        audioSource = GetComponent<AudioSource>();
        if (audioSource == null)
        {
            audioSource = gameObject.AddComponent<AudioSource>();
        }
    }

    void Update()
    {
        if (target != null && nav != null && nav.enabled && gameObject.activeSelf && !isBoss) // ������ �ƴ� ���� �̵�
        {
            nav.SetDestination(target.position); // ��ǥ ��ġ�� �̵�
        }
    }

    // �ʱ�ȭ �޼���
    public void Initialize()
    {
        currentHealth = maxHealth;
        if (nav != null && !isBoss)
        {
            nav.enabled = true; // NavMeshAgent �ٽ� Ȱ��ȭ
        }
    }

    // �������� �޴� �Լ�
    public void TakeDamage(int damage)
    {
        currentHealth -= damage;
        if (currentHealth <= 0)
        {
            StartCoroutine(Die());
        }
    }

    // �� ��� ó��
    private IEnumerator Die()
    {
        Debug.Log("���� �׾�ϴ�.");

        if (deathSound != null && audioSource != null)
        {
            audioSource.PlayOneShot(deathSound);
        }

        // �Ҹ� ����� ���� ������ ���
        yield return new WaitWhile(() => audioSource.isPlaying);

        gameObject.SetActive(false); // �� ��Ȱ��ȭ

        // ���� �߰�
        GameManager.Instance.AddScore(10);

        // GameManager���� �˸�
        FindObjectOfType<GameManager>().CheckMonsters();

        // ���� ��ġ�� deathReplacementPrefab�� �ν��Ͻ�ȭ
        if (deathReplacementPrefab != null)
        {
            currentPrefabInstance = Instantiate(deathReplacementPrefab, transform.position, transform.rotation);
            Debug.Log("deathReplacementPrefab�� ��ġ�� �ν��Ͻ�ȭ: " + transform.position);
        }
        else
        {
            Debug.LogError("deathReplacementPrefab�� �Ҵ���� �ʾҽ��ϴ�!");
        }

        // 1�� ��� �� Prefab �ν��Ͻ��� �ı�
        yield return new WaitForSeconds(1.0f);

        if (currentPrefabInstance != null)
        {
            Destroy(currentPrefabInstance);
            Debug.Log("deathReplacementPrefab �ν��Ͻ��� �ı��߽��ϴ�.");
        }

        // gameObject�� ��ȿ���� Ȯ�� �� �ı�
        if (gameObject != null)
        {
            Destroy(gameObject); // ���� GameObject �ı�
            Debug.Log("�� ���� ������Ʈ�� �ı��߽��ϴ�.");
        }
        else
        {
            Debug.LogError("���� ������Ʈ�� �̹� null�̱� ������ �ı��� �� �����ϴ�.");
        }
    }
}
