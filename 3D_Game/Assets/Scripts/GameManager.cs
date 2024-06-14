using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public GameObject[] monsters; // 모든 몬스터를 담는 배열
    public GameObject platformPrefab; // 생성할 발판 프리팹
    public Vector3 platformPosition = Vector3.zero; // 발판 위치

    private bool platformSpawned = false; // 발판이 생성되었는지 여부

    private void Start()
    {
        // 모든 몬스터를 초기화
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
