using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.AI;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }
    public GameObject menuSet;

    public GameObject platformPrefab_stage1; // stage1에서 사용할 발판 프리팹
    public GameObject platformPrefab_stage2; // stage2에서 사용할 발판 프리팹
    public Vector3 platformPosition_stage1 = new Vector3(0, 0.75f, 0.31f); // stage1에서 발판 위치
    public Vector3 platformPosition_stage2 = new Vector3(0, 1.0f, 0.31f); // stage2에서 발판 위치
    private GameObject platform; // 생성된 발판 참조

    public GameObject[] blockPrefabs; // 생성할 블록 프리팹들
    public Vector3[] blockPositions; // 블록의 위치들
    public AudioClip[] blockDeathSounds; // 블록이 죽을 때 재생할 소리들

    private bool platformSpawned = false; // 발판이 생성되었는지 여부
    private bool blocksSpawned = false; // 블록이 생성되었는지 여부

    public int score = 0; // 점수 변수
    public Text scoreText; // 점수를 표시할 UI 텍스트

    void Update()
    {
        // 서브 메뉴
        if (Input.GetButtonDown("Cancel"))
        {
            if (menuSet.activeSelf)
            {
                menuSet.SetActive(false);
            }
            else
            {
                menuSet.SetActive(true);
            }
        }
    }

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
        UpdateScoreText(); // 초기 점수 텍스트 업데이트
    }

    public void AddScore(int points)
    {
        score += points;
        UpdateScoreText();
    }

    void UpdateScoreText()
    {
        if (scoreText != null)
        {
            scoreText.text = "Score: " + score.ToString(); // 점수 텍스트 업데이트
        }
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
        if (!blocksSpawned && SceneManager.GetActiveScene().name == "bossStage")
        {
            SpawnBlocks(); // 블록 생성
            blocksSpawned = true; // 블록이 생성되었음을 표시
        }
    }

    private void SpawnPlatform()
    {
        string currentSceneName = SceneManager.GetActiveScene().name;
        if (currentSceneName == "stage1" && platformPrefab_stage1 != null)
        {
            platform = Instantiate(platformPrefab_stage1, platformPosition_stage1, Quaternion.identity);
        }
        else if (currentSceneName == "stage2" && platformPrefab_stage2 != null)
        {
            platform = Instantiate(platformPrefab_stage2, platformPosition_stage2, Quaternion.identity);
        }
        else
        {
            Debug.LogError("현재 씬에 대한 발판 프리팹이 지정되지 않았습니다: " + currentSceneName);
            return;
        }

        platform.tag = "Platform";
        platformSpawned = true;
        Debug.Log("발판이 생성되었습니다: " + platform.transform.position);
    }

    private void SpawnBlocks()
    {
        for (int i = 0; i < blockPrefabs.Length; i++)
        {
            Vector3 position = blockPositions.Length > i ? blockPositions[i] : Vector3.zero;
            GameObject block = Instantiate(blockPrefabs[i], position, Quaternion.identity);
            Debug.Log("블록이 생성되었습니다: " + position);
            Enemy blockScript = block.GetComponent<Enemy>();
            if (blockScript != null)
            {
                blockScript.deathSound = blockDeathSounds.Length > i ? blockDeathSounds[i] : null;
                blockScript.maxHealth = 1; // 블록의 체력을 1로 설정
                blockScript.currentHealth = 1;
                blockScript.target = null; // 블록은 플레이어를 따라가지 않음
                block.tag = "Block"; // 블록을 다른 태그로 설정
                if (blockScript.nav != null)
                {
                    blockScript.nav.enabled = false; // NavMeshAgent 비활성화
                }

                // 블록에 AudioSource 컴포넌트가 없으면 추가
                AudioSource audioSource = block.GetComponent<AudioSource>();
                if (audioSource == null)
                {
                    audioSource = block.AddComponent<AudioSource>();
                }
                audioSource.playOnAwake = false;
                audioSource.spatialBlend = 1.0f; // 3D 사운드 설정
            }
            else
            {
                Debug.LogError("Block 스크립트가 제대로 할당되지 않았습니다.");
            }
        }
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
        blocksSpawned = false; // 씬 로드 시 블록 생성 여부 초기화
        InitMonsters();
        InitializeNavMeshAgents(); // NavMeshAgent 초기화
    }

    private void InitMonsters()
    {
        GameObject[] monsters = GameObject.FindGameObjectsWithTag("Enemy");
        foreach (GameObject monster in monsters)
        {
            Enemy enemy = monster.GetComponent<Enemy>();
            if (enemy != null)
            {
                enemy.target = GameObject.FindWithTag("Player").transform; // 플레이어를 타겟으로 설정
                enemy.Initialize(); // 적 초기화
            }
        }
    }

    private void InitializeNavMeshAgents()
    {
        GameObject[] enemies = GameObject.FindGameObjectsWithTag("Enemy");
        foreach (GameObject enemy in enemies)
        {
            NavMeshAgent agent = enemy.GetComponent<NavMeshAgent>();
            if (agent != null)
            {
                agent.enabled = false;
                agent.enabled = true;
            }
        }
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

    public void GameExit()
    {
        Application.Quit();
    }
}
