using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Boss : MonoBehaviour
{
    public Transform target;
    public int maxHealth = 100; // �ִ� ü��
    private int currentHealth; // ���� ü��

    public GameObject deathReplacementPrefab; // ���� �׾��� �� ��ü�� Prefab
    private GameObject currentPrefabInstance; // ���� Prefab �ν��Ͻ�

    private BoxCollider boxCollider; // �ڽ� �ݶ��̴� ������Ʈ
    private UnityEngine.AI.NavMeshAgent nav; // �׺���̼� �޽� ������Ʈ ������Ʈ

    private void Awake()
    {
        boxCollider = GetComponent<BoxCollider>();
        nav = GetComponent<UnityEngine.AI.NavMeshAgent>();
        currentHealth = maxHealth; // �ʱ� ü�� ����
    }

    private void Update()
    {
        nav.SetDestination(target.position); // ��ǥ ��ġ�� �̵�
    }

    // �������� �޴� �Լ�
    public void TakeDamage(int damage)
    {
        currentHealth -= damage;
        if (currentHealth <= 0)
        {
            Die();
        }
    }

    // �� ��� ó��
    private void Die()
    {
        gameObject.SetActive(false); // �� ��Ȱ��ȭ
        FindObjectOfType<GameManager>().CheckMonsters(); // GameManager���� �˸�
        // ���� ��ġ�� deathReplacementPrefab�� �ν��Ͻ�ȭ
        currentPrefabInstance = Instantiate(deathReplacementPrefab, transform.position, transform.rotation);

        StartCoroutine(DestroyAfterDelay(0.5f)); // 0.5�� �Ŀ� �ı� ó��
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

        Destroy(gameObject); // ���� GameObject �ı�
    }
}
