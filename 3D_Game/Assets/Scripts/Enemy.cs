using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Enemy : MonoBehaviour
{
    public Transform target;
    public int maxHealth = 100; // �ִ� ü��
    private int currentHealth; // ���� ü��

    private BoxCollider boxCollider; // �ڽ� �ݶ��̴� ������Ʈ
    private NavMeshAgent nav; // �׺���̼� �޽� ������Ʈ ������Ʈ

    private void Awake()
    {
        boxCollider = GetComponent<BoxCollider>();
        nav = GetComponent<NavMeshAgent>();
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
    }
}
