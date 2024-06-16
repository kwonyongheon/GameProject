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

    public GameObject platformPrefab_stage1; // stage1���� ����� ���� ������
    public GameObject platformPrefab_stage2; // stage2���� ����� ���� ������
    public Vector3 platformPosition_stage1 = new Vector3(0, 0.75f, 0.31f); // stage1���� ���� ��ġ
    public Vector3 platformPosition_stage2 = new Vector3(0, 1.0f, 0.31f); // stage2���� ���� ��ġ
    private GameObject platform; // ������ ���� ����

    public GameObject[] blockPrefabs; // ������ ��� �����յ�
    public Vector3[] blockPositions; // ����� ��ġ��
    public AudioClip[] blockDeathSounds; // ����� ���� �� ����� �Ҹ���

    private bool platformSpawned = false; // ������ �����Ǿ����� ����
    private bool blocksSpawned = false; // ����� �����Ǿ����� ����

    public int score = 0; // ���� ����
    public Text scoreText; // ������ ǥ���� UI �ؽ�Ʈ

    void Update()
    {
        // ���� �޴�
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
        UpdateScoreText(); // �ʱ� ���� �ؽ�Ʈ ������Ʈ
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
            scoreText.text = "Score: " + score.ToString(); // ���� �ؽ�Ʈ ������Ʈ
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
            SpawnBlocks(); // ��� ����
            blocksSpawned = true; // ����� �����Ǿ����� ǥ��
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
            Debug.LogError("���� ���� ���� ���� �������� �������� �ʾҽ��ϴ�: " + currentSceneName);
            return;
        }

        platform.tag = "Platform";
        platformSpawned = true;
        Debug.Log("������ �����Ǿ����ϴ�: " + platform.transform.position);
    }

    private void SpawnBlocks()
    {
        for (int i = 0; i < blockPrefabs.Length; i++)
        {
            Vector3 position = blockPositions.Length > i ? blockPositions[i] : Vector3.zero;
            GameObject block = Instantiate(blockPrefabs[i], position, Quaternion.identity);
            Debug.Log("����� �����Ǿ����ϴ�: " + position);
            Enemy blockScript = block.GetComponent<Enemy>();
            if (blockScript != null)
            {
                blockScript.deathSound = blockDeathSounds.Length > i ? blockDeathSounds[i] : null;
                blockScript.maxHealth = 1; // ����� ü���� 1�� ����
                blockScript.currentHealth = 1;
                blockScript.target = null; // ����� �÷��̾ ������ ����
                block.tag = "Block"; // ����� �ٸ� �±׷� ����
                if (blockScript.nav != null)
                {
                    blockScript.nav.enabled = false; // NavMeshAgent ��Ȱ��ȭ
                }

                // ��Ͽ� AudioSource ������Ʈ�� ������ �߰�
                AudioSource audioSource = block.GetComponent<AudioSource>();
                if (audioSource == null)
                {
                    audioSource = block.AddComponent<AudioSource>();
                }
                audioSource.playOnAwake = false;
                audioSource.spatialBlend = 1.0f; // 3D ���� ����
            }
            else
            {
                Debug.LogError("Block ��ũ��Ʈ�� ����� �Ҵ���� �ʾҽ��ϴ�.");
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
        // �� �ε� �� �ʱ�ȭ�ؾ� �ϴ� ������Ʈ�� ���⿡�� �����մϴ�.
        platformSpawned = false;
        platform = null;
        blocksSpawned = false; // �� �ε� �� ��� ���� ���� �ʱ�ȭ
        InitMonsters();
        InitializeNavMeshAgents(); // NavMeshAgent �ʱ�ȭ
    }

    private void InitMonsters()
    {
        GameObject[] monsters = GameObject.FindGameObjectsWithTag("Enemy");
        foreach (GameObject monster in monsters)
        {
            Enemy enemy = monster.GetComponent<Enemy>();
            if (enemy != null)
            {
                enemy.target = GameObject.FindWithTag("Player").transform; // �÷��̾ Ÿ������ ����
                enemy.Initialize(); // �� �ʱ�ȭ
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
