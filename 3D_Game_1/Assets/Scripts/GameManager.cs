using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    public GameObject platformPrefab_stage1; // stage1���� ����� ���� ������
    public GameObject platformPrefab_stage2; // stage2���� ����� ���� ������
    public Vector3 platformPosition_stage1 = new Vector3(0, 0.75f, 0.31f); // stage1���� ���� ��ġ
    public Vector3 platformPosition_stage2 = new Vector3(0, 1.0f, 0.31f); // stage2���� ���� ��ġ
    private GameObject platform; // ������ ���� ����

    private bool platformSpawned = false; // ������ �����Ǿ����� ����

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject); // �� ��ȯ �� �ı����� �ʵ��� ����
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void Start()
    {
        // ��� ���͸� �ʱ�ȭ
        InitMonsters();
    }

    public void CheckMonsters()
    {
        GameObject[] monsters = GameObject.FindGameObjectsWithTag("Enemy");
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
        string currentSceneName = SceneManager.GetActiveScene().name;
        if (currentSceneName == "stage1")
        {
            platform = Instantiate(platformPrefab_stage1, platformPosition_stage1, Quaternion.identity);
        }
        else if (currentSceneName == "stage2")
        {
            platform = Instantiate(platformPrefab_stage2, platformPosition_stage2, Quaternion.identity);
        }
        platform.tag = "Platform";
        platformSpawned = true;
        Debug.Log("Platform spawned at position: " + platform.transform.position);
    }

    public void LoadNextScene()
    {
        string currentSceneName = SceneManager.GetActiveScene().name;
        if (currentSceneName == "stage1")
        {
            SceneManager.LoadScene("stage2");
        }
        else if (currentSceneName == "stage2")
        {
            SceneManager.LoadScene("bossStage");
        }
    }

    public void OnSceneLoaded(Scene scene)
    {
        // �� �ε� �� �ʱ�ȭ�ؾ� �ϴ� ������Ʈ�� ���⿡�� �����մϴ�.
        platformSpawned = false;
        platform = null;
        InitMonsters();
    }

    private void InitMonsters()
    {
        GameObject[] monsters = GameObject.FindGameObjectsWithTag("Enemy");
        // �ʿ��� �ʱ�ȭ �۾��� ���⿡ �߰��� �� �ֽ��ϴ�.
    }

    private void OnEnable()
    {
        SceneManager.sceneLoaded += OnSceneLoadedHandler;
    }

    private void OnDisable()
    {
        SceneManager.sceneLoaded -= OnSceneLoadedHandler;
    }

    private void OnSceneLoadedHandler(Scene scene, LoadSceneMode mode)
    {
        OnSceneLoaded(scene);
    }
}
