using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public GameObject[] monsters; // ��� ���͸� ��� �迭
    public GameObject platformPrefab; // ������ ���� ������
    public Vector3 platformPosition = Vector3.zero; // ���� ��ġ

    private bool platformSpawned = false; // ������ �����Ǿ����� ����

    private void Start()
    {
        // ��� ���͸� �ʱ�ȭ
        monsters = GameObject.FindGameObjectsWithTag("Enemy");
    }

    public void CheckMonsters()
    {
        foreach (var monster in monsters)
        {
            if (monster.activeSelf)
                return;
        }
        if (!platformSpawned)
        {
            SpawnPlatform();
        }
    }

    private void SpawnPlatform()
    {
        Instantiate(platformPrefab, platformPosition, Quaternion.identity).tag = "Platform";
        platformSpawned = true;
    }
}
