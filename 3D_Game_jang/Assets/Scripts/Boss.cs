using System.Collections;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.UI; // UI ���ӽ����̽� �߰�

public class Boss : MonoBehaviour
{
    public Transform target;
    public int maxHealth = 100; // �ִ� ü��
    private int currentHealth; // ���� ü��

    public GameObject deathReplacementPrefab; // ���� �׾��� �� ��ü�� Prefab
    private GameObject currentPrefabInstance; // ���� Prefab �ν��Ͻ�

    private BoxCollider boxCollider; // �ڽ� �ݶ��̴� ������Ʈ
    private NavMeshAgent nav; // �׺���̼� �޽� ������Ʈ ������Ʈ

    public Slider healthSlider;

    private void Awake()
    {
        boxCollider = GetComponent<BoxCollider>();
        nav = GetComponent<NavMeshAgent>();
        currentHealth = maxHealth; // �ʱ� ü�� ����

        UpdateHealthUI(); // �ʱ� UI ������Ʈ
    }

    private void Update()
    {
        nav.SetDestination(target.position); // ��ǥ ��ġ�� �̵�
    }

    // �������� �޴� �Լ�
    public void TakeDamage(int damage)
    {
        currentHealth -= damage;
        UpdateHealthUI(); // ü�� ���� �� UI ������Ʈ

        if (currentHealth <= 0)
        {
            Die();
        }
    }

    private void Die()
    {
        // �� ��� ó�� ����
        UpdateHealthUI(); // UI ������Ʈ
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

    private void UpdateHealthUI()
    {
        healthSlider.value = (float)currentHealth / maxHealth; // ü�� �����̴� ������Ʈ (�����)
    }
}
