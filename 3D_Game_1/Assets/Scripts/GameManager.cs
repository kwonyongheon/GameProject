using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    public GameObject platformPrefab_stage1; // stage1에서 사용할 발판 프리팹
    public GameObject platformPrefab_stage2; // stage2에서 사용할 발판 프리팹
    public Vector3 platformPosition_stage1 = new Vector3(0, 0.75f, 0.31f); // stage1에서 발판 위치
    public Vector3 platformPosition_stage2 = new Vector3(0, 1.0f, 0.31f); // stage2에서 발판 위치
    private GameObject platform; // 생성된 발판 참조

    private bool platformSpawned = false; // 발판이 생성되었는지 여부

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject); // 씬 전환 시 파괴되지 않도록 설정
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void Start()
    {
        // 모든 몬스터를 초기화
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
        // 씬 로드 시 초기화해야 하는 오브젝트를 여기에서 설정합니다.
        platformSpawned = false;
        platform = null;
        InitMonsters();
    }

    private void InitMonsters()
    {
        GameObject[] monsters = GameObject.FindGameObjectsWithTag("Enemy");
        // 필요한 초기화 작업을 여기에 추가할 수 있습니다.
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
