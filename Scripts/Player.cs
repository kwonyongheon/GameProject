using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class Player : MonoBehaviour
{
    public static Player Instance { get; private set; }

    public float walkSpeed = 3f;
    public float runSpeed = 6f;
    public float jumpForce = 3f;
    public CharacterController controller;
    public Transform cam;
    public Transform weaponPoint;

    public GameObject[] weapons;
    public bool[] hasWeapons;
    public int ammo;
    public int maxAmmo;

    public int maxHealth = 200;
    public int currentHealth;
    private bool isDead = false;
    public float deathLookUpSpeed = 2f;
    public float deathDuration = 2f;

    public string stage2SceneName = "stage2";
    public string bossStageSceneName = "bossStage";

    public Image crosshair;

    private Vector3 moveDirection;
    private float gravity = 9.81f;
    private float yVelocity = 0f;
    private int jumpCount = 0;
    private int maxJumpCount = 2;

    private float xRotation = 0f;
    public float mouseSensitivity = 100f;

    private bool sDown1;
    private bool sDown2;
    private bool sDown3;
    private bool isSwap;

    private Weapon equipWeapon;
    private int equipWeaponIndex = -1;

    private GameObject nearObject;

    private PlayerAiming playerAiming;

    public AudioClip jumpSound;
    private AudioSource audioSource;

    public Text healthText;
    public float moveSpeed = 5f;  // 추가된 변수
    public bool canMove = true;   // 추가된 변수

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }

        audioSource = GetComponent<AudioSource>();
        if (audioSource == null)
        {
            Debug.LogError("AudioSource 컴포넌트가 없습니다!");
        }

        if (crosshair != null)
        {
            DontDestroyOnLoad(crosshair.gameObject);
        }
    }

    private void Start()
    {
        SceneManager.sceneLoaded += OnSceneLoaded;

        controller = GetComponent<CharacterController>();
        playerAiming = GetComponent<PlayerAiming>();
        if (playerAiming == null)
        {
            Debug.LogError("PlayerAiming 컴포넌트가 없습니다!");
        }

        Cursor.lockState = CursorLockMode.Locked;

        for (int i = 0; i < weapons.Length; i++)
        {
            if (weapons[i] != null)
            {
                Debug.Log("무기 " + i + ": " + weapons[i].name);
            }
            else
            {
                Debug.LogError("무기 " + i + "가 null입니다!");
            }
        }

        currentHealth = maxHealth;

        if (crosshair != null)
        {
            crosshair.enabled = false;
        }

        GameObject healthTextObject = GameObject.Find("HealthText");
        if (healthTextObject != null)
        {
            healthText = healthTextObject.GetComponent<Text>();
        }
        else
        {
            Debug.LogError("HealthText 오브젝트를 찾을 수 없습니다!");
        }

        UpdateHealthUI();
    }

    private void Update()
    {
        if (!isDead)
        {
            if (canMove)  // 이동 가능 여부 체크
            {
                Move();
                Jump();
                Rotate();
                GetInput();
                Swap();
                Interaction();
                Attack();
            }
        }

        if (equipWeapon != null && Input.GetMouseButtonDown(1))
        {
            Aim(true);
        }
        else if (Input.GetMouseButtonUp(1))
        {
            Aim(false);
        }
    }

    private void Move()
    {
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        Vector3 direction = new Vector3(horizontal, 0f, vertical).normalized;
        float currentSpeed = canMove ? (Input.GetKey(KeyCode.LeftShift) ? runSpeed : walkSpeed) : 0;

        if (direction.magnitude >= 0.1f)
        {
            Vector3 moveDir = transform.right * horizontal + transform.forward * vertical;
            controller.Move(moveDir * currentSpeed * Time.deltaTime);
        }

        if (controller.isGrounded)
        {
            if (yVelocity < 0)
            {
                yVelocity = -gravity * Time.deltaTime;
                jumpCount = 0;
            }
        }
        else
        {
            yVelocity -= gravity * Time.deltaTime;
        }

        moveDirection.y = yVelocity;
        controller.Move(moveDirection * Time.deltaTime);
    }

    private void Rotate()
    {
        float mouseX = Input.GetAxis("Mouse X") * mouseSensitivity * Time.deltaTime;
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity * Time.deltaTime;

        xRotation -= mouseY;
        xRotation = Mathf.Clamp(xRotation, -90f, 90f);

        cam.localRotation = Quaternion.Euler(xRotation, 0f, 0f);
        transform.Rotate(Vector3.up * mouseX);
    }

    private void Jump()
    {
        if (Input.GetButtonDown("Jump") && jumpCount < maxJumpCount)
        {
            yVelocity = jumpForce;
            jumpCount++;

            if (jumpSound != null && audioSource != null)
            {
                audioSource.PlayOneShot(jumpSound);
            }
        }
    }

    private void GetInput()
    {
        sDown1 = Input.GetButtonDown("Swap1");
        sDown2 = Input.GetButtonDown("Swap2");
        sDown3 = Input.GetButtonDown("Swap3");
    }

    private void Swap()
    {
        if (sDown1 && (!hasWeapons[0] || equipWeaponIndex == 0)) return;
        if (sDown2 && (!hasWeapons[1] || equipWeaponIndex == 1)) return;
        if (sDown3 && (!hasWeapons[2] || equipWeaponIndex == 2)) return;

        int weaponIndex = -1;
        if (sDown1) weaponIndex = 0;
        if (sDown2) weaponIndex = 1;
        if (sDown3) weaponIndex = 2;

        if ((sDown1 || sDown2 || sDown3) && !isSwap)
        {
            if (equipWeapon != null)
            {
                equipWeapon.gameObject.SetActive(false);
            }
            equipWeaponIndex = weaponIndex;

            if (weaponIndex >= 0 && weaponIndex < weapons.Length)
            {
                Debug.Log("무기 교체: " + weaponIndex);

                if (weapons[weaponIndex] == null)
                {
                    Debug.LogError("무기 " + weaponIndex + "가 null입니다!");
                    return;
                }

                equipWeapon = weapons[weaponIndex].GetComponent<Weapon>();

                if (equipWeapon != null)
                {
                    Debug.Log("성공적으로 무기 컴포넌트를 가져왔습니다: " + weaponIndex);
                    equipWeapon.gameObject.SetActive(true);

                    if (weaponPoint != null)
                    {
                        equipWeapon.transform.SetParent(weaponPoint);
                        equipWeapon.transform.localPosition = Vector3.zero;
                        equipWeapon.transform.localRotation = Quaternion.identity;
                    }
                    else
                    {
                        equipWeapon.transform.SetParent(cam);
                        equipWeapon.transform.localPosition = new Vector3(0.5f, -0.5f, 1f);
                        equipWeapon.transform.localRotation = Quaternion.identity;
                    }

                    if (playerAiming != null)
                    {
                        playerAiming.currentWeapon = equipWeapon;
                    }
                    else
                    {
                        Debug.LogError("PlayerAiming 컴포넌트가 없습니다!");
                    }

                    isSwap = true;
                    Invoke("SwapOut", 0.4f);
                }
                else
                {
                    Debug.LogError("무기 컴포넌트를 가져올 수 없습니다: " + weaponIndex);
                }
            }
            else
            {
                Debug.LogError("무기 인덱스 " + weaponIndex + "가 범위를 벗어났습니다!");
            }
        }
    }

    private void SwapOut()
    {
        isSwap = false;
    }

    private void Interaction()
    {
        if (nearObject != null && nearObject.CompareTag("Weapon"))
        {
            Item item = nearObject.GetComponent<Item>();
            int weaponIndex = item.value;
            hasWeapons[weaponIndex] = true;

            Destroy(nearObject);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Item"))
        {
            Item item = other.GetComponent<Item>();
            if (item.type == Item.Type.Ammo)
            {
                foreach (GameObject weapon in weapons)
                {
                    if (weapon != null)
                    {
                        Weapon weaponScript = weapon.GetComponent<Weapon>();
                        if (weaponScript != null)
                        {
                            weaponScript.curAmmo = weaponScript.maxAmmo;
                        }
                    }
                }
            }
            Destroy(other.gameObject);
        }

        if (other.CompareTag("Weapon"))
        {
            nearObject = other.gameObject;
        }

        if (other.CompareTag("Platform"))
        {
            Debug.Log("플레이어가 플랫폼에 도착했습니다.");
            GameManager.Instance.LoadNextScene();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Weapon"))
        {
            nearObject = null;
        }
    }

    private void OnControllerColliderHit(ControllerColliderHit hit)
    {
        if (hit.gameObject.CompareTag("Enemy"))
        {
            TakeDamage(5);
        }
    }

    public void TakeDamage(int damage)
    {
        currentHealth -= damage;
        Debug.Log("플레이어가 피해를 입었습니다. 현재 체력: " + currentHealth);
        UpdateHealthUI();
        if (currentHealth <= 0 && !isDead)
        {
            StartCoroutine(Die());
        }
    }

    private IEnumerator Die()
    {
        isDead = true;
        Debug.Log("플레이어가 죽었습니다.");

        float elapsedTime = 0f;
        while (elapsedTime < deathDuration)
        {
            float angle = Mathf.Lerp(0, -45, elapsedTime / deathDuration);
            cam.localRotation = Quaternion.Euler(angle, 0f, 0f);
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        // 죽었을 때 마우스 입력 비활성화
        canMove = false;
        Cursor.lockState = CursorLockMode.None; // 마우스 커서 락 해제
        Cursor.visible = true; // 마우스 커서 보이기

        if (crosshair != null)
        {
            crosshair.enabled = false; // 크로스헤어 숨기기
        }
    }

    private void Attack()
    {
        if (Input.GetMouseButtonDown(0) && equipWeapon != null)
        {
            equipWeapon.Use();
        }
    }

    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        if (scene.name == "stage1")
        {
            SetPlayerStartPosition(new Vector3(-16.63f, 1.49f, 3.6f));
        }
        else if (scene.name == "stage2")
        {
            SetPlayerStartPosition(new Vector3(-18.78f, 6.93f, -22.97f));
        }
        else if (scene.name == "bossStage")
        {
            SetPlayerStartPosition(new Vector3(0, -1.8f, 4.83f));
        }

        InitializeCrosshair();

        if (GameManager.Instance != null)
        {
            GameManager.Instance.OnSceneLoaded(scene);
        }
    }

    private void SetPlayerStartPosition(Vector3 startPosition)
    {
        controller.enabled = false;
        transform.position = startPosition;
        controller.enabled = true;
    }

    private void Aim(bool isAiming)
    {
        if (crosshair != null)
        {
            crosshair.enabled = isAiming;
        }
    }

    private void InitializeCrosshair()
    {
        if (crosshair == null)
        {
            crosshair = GameObject.FindGameObjectWithTag("Crosshair").GetComponent<Image>();
            if (crosshair != null)
            {
                crosshair.enabled = false;
                DontDestroyOnLoad(crosshair.gameObject);
            }
            else
            {
                Debug.LogError("크로스헤어를 찾을 수 없습니다!");
            }
        }
    }

    private void OnDestroy()
    {
        SceneManager.sceneLoaded -= OnSceneLoaded;
    }

    private void UpdateHealthUI()
    {
        if (healthText != null)
        {
            healthText.text = "Health: " + currentHealth.ToString(); // 체력 텍스트 업데이트
        }
        else
        {
            Debug.LogError("HealthText 컴포넌트가 없습니다!");
        }
    }
}
