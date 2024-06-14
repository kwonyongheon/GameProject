using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class Player : MonoBehaviour
{
    public static Player Instance { get; private set; }

    public float walkSpeed = 5f; // 걷기 속도
    public float runSpeed = 10f; // 달리기 속도
    public float jumpForce = 5f; // 점프 힘
    public CharacterController controller; // 캐릭터 컨트롤러 컴포넌트
    public Transform cam; // 카메라 Transform
    public Transform weaponPoint; // 무기 장착 위치

    public GameObject[] weapons; // 무기 배열
    public bool[] hasWeapons; // 무기 소유 여부
    public int ammo; // 현재 탄약
    public int maxAmmo; // 최대 탄약

    public int maxHealth = 100; // 최대 체력
    private int currentHealth; // 현재 체력
    private bool isDead = false; // 플레이어 사망 여부
    public float deathLookUpSpeed = 2f; // 사망 시 하늘을 바라보는 속도
    public float deathDuration = 2f; // 사망 연출 지속 시간

    public string stage2SceneName = "stage2"; // stage2 씬 이름
    public string bossStageSceneName = "bossStage"; // bossStage 씬 이름

    public Image crosshair; // 조준점 이미지

    private Vector3 moveDirection; // 이동 방향 벡터
    private float gravity = 9.81f; // 중력 값
    private float yVelocity = 0f; // Y 축 속도 (중력 및 점프)
    private int jumpCount = 0; // 현재 점프 횟수
    private int maxJumpCount = 2; // 최대 점프 횟수 (더블 점프)

    private float xRotation = 0f; // X 축 회전 값 (카메라 회전)
    public float mouseSensitivity = 100f; // 마우스 감도

    private bool sDown1; // 무기 스왑 1번 키 입력
    private bool sDown2; // 무기 스왑 2번 키 입력
    private bool sDown3; // 무기 스왑 3번 키 입력
    private bool isSwap; // 무기 스왑 상태 여부

    private Weapon equipWeapon; // 현재 장착된 무기
    private int equipWeaponIndex = -1; // 현재 장착된 무기 인덱스

    private GameObject nearObject; // 근처 오브젝트

    private PlayerAiming playerAiming; // PlayerAiming 컴포넌트

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

        // Crosshair를 DontDestroyOnLoad로 설정
        if (crosshair != null)
        {
            DontDestroyOnLoad(crosshair.gameObject);
        }
    }

    private void Start()
    {
        // 씬 로드 이벤트 등록
        SceneManager.sceneLoaded += OnSceneLoaded;

        // 캐릭터 컨트롤러 컴포넌트 가져오기
        controller = GetComponent<CharacterController>();
        // PlayerAiming 컴포넌트 가져오기
        playerAiming = GetComponent<PlayerAiming>();
        if (playerAiming == null)
        {
            Debug.LogError("PlayerAiming component is missing!");
        }

        // 커서를 화면 중앙에 고정하고 숨김
        Cursor.lockState = CursorLockMode.Locked;

        // 디버그 로그로 무기 배열 확인
        for (int i = 0; i < weapons.Length; i++)
        {
            if (weapons[i] != null)
            {
                Debug.Log("Weapon " + i + ": " + weapons[i].name);
            }
            else
            {
                Debug.LogError("Weapon " + i + " is null!");
            }
        }

        currentHealth = maxHealth; // 초기 체력 설정

        // Crosshair 설정
        if (crosshair != null)
        {
            crosshair.enabled = false; // 초기화 시 Crosshair 비활성화
        }
    }

    private void Update()
    {
        if (!isDead)
        {
            Move(); // 이동 처리
            Jump(); // 점프 처리
            Rotate(); // 회전 처리
            GetInput(); // 입력 처리
            Swap(); // 무기 교체
            Interaction(); // 상호작용
            Attack(); // 공격 처리
        }

        if (equipWeapon != null && Input.GetMouseButtonDown(1))
        {
            // 오른쪽 마우스 버튼을 누르면 조준 모드로 전환
            Aim(true);
        }
        else if (Input.GetMouseButtonUp(1))
        {
            // 오른쪽 마우스 버튼을 떼면 조준 모드를 해제
            Aim(false);
        }
    }

    private void Move()
    {
        float horizontal = Input.GetAxis("Horizontal"); // 수평 입력 (A, D 또는 좌우 화살표 키)
        float vertical = Input.GetAxis("Vertical"); // 수직 입력 (W, S 또는 상하 화살표 키)

        Vector3 direction = new Vector3(horizontal, 0f, vertical).normalized; // 입력 방향 벡터 계산
        float currentSpeed = Input.GetKey(KeyCode.LeftShift) ? runSpeed : walkSpeed; // 달리기/걷기 속도 설정

        if (direction.magnitude >= 0.1f)
        {
            Vector3 moveDir = transform.right * horizontal + transform.forward * vertical; // 이동 방향 벡터 계산 (월드 좌표계 기준)
            controller.Move(moveDir * currentSpeed * Time.deltaTime); // 캐릭터 이동
        }

        // 중력 적용
        if (controller.isGrounded)
        {
            if (yVelocity < 0)
            {
                yVelocity = -gravity * Time.deltaTime; // 지면에 있을 때 중력 초기화
                jumpCount = 0; // 지면에 있을 때 점프 횟수 초기화
            }
        }
        else
        {
            yVelocity -= gravity * Time.deltaTime; // 공중에 있을 때 중력 적용
        }

        moveDirection.y = yVelocity; // 이동 방향에 Y 축 속도 적용
        controller.Move(moveDirection * Time.deltaTime); // 캐릭터 이동
    }

    private void Rotate()
    {
        float mouseX = Input.GetAxis("Mouse X") * mouseSensitivity * Time.deltaTime; // 마우스 X 축 입력
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity * Time.deltaTime; // 마우스 Y 축 입력

        xRotation -= mouseY; // X 축 회전 값 갱신
        xRotation = Mathf.Clamp(xRotation, -90f, 90f); // X 축 회전 값 제한 (상하 90도 제한)

        cam.localRotation = Quaternion.Euler(xRotation, 0f, 0f); // 카메라 회전 적용
        transform.Rotate(Vector3.up * mouseX); // 캐릭터 회전 적용
    }

    private void Jump()
    {
        if (Input.GetButtonDown("Jump") && jumpCount < maxJumpCount)
        {
            yVelocity = jumpForce; // 점프 힘 적용
            jumpCount++; // 점프 횟수 증가
        }
    }

    private void GetInput()
    {
        sDown1 = Input.GetButtonDown("Swap1"); // 무기 스왑 1번 키 입력
        sDown2 = Input.GetButtonDown("Swap2"); // 무기 스왑 2번 키 입력
        sDown3 = Input.GetButtonDown("Swap3"); // 무기 스왑 3번 키 입력
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
                Debug.Log("Swapping to weapon index: " + weaponIndex);

                if (weapons[weaponIndex] == null)
                {
                    Debug.LogError("Weapon at index " + weaponIndex + " is null!");
                    return;
                }

                equipWeapon = weapons[weaponIndex].GetComponent<Weapon>();

                if (equipWeapon != null)
                {
                    Debug.Log("Successfully got Weapon component for weapon index: " + weaponIndex);
                    equipWeapon.gameObject.SetActive(true);

                    // 무기를 손에 붙이기
                    if (weaponPoint != null)
                    {
                        equipWeapon.transform.SetParent(weaponPoint);
                        equipWeapon.transform.localPosition = Vector3.zero; // 위치 초기화
                        equipWeapon.transform.localRotation = Quaternion.identity; // 회전 초기화
                    }
                    else
                    {
                        // 무기 장착 위치가 없을 경우, 카메라 앞에 무기 배치
                        equipWeapon.transform.SetParent(cam);
                        equipWeapon.transform.localPosition = new Vector3(0.5f, -0.5f, 1f); // 적절한 위치 설정
                        equipWeapon.transform.localRotation = Quaternion.identity;
                    }

                    if (playerAiming != null)
                    {
                        playerAiming.currentWeapon = equipWeapon; // PlayerAiming에 현재 무기 설정
                    }
                    else
                    {
                        Debug.LogError("PlayerAiming component is missing!");
                    }

                    isSwap = true;
                    Invoke("SwapOut", 0.4f); // 0.4초 후 SwapOut 함수 호출
                }
                else
                {
                    Debug.LogError("equipWeapon is null after getting component for weapon index: " + weaponIndex);
                }
            }
            else
            {
                Debug.LogError("weaponIndex " + weaponIndex + " is out of bounds!");
            }
        }
    }

    private void SwapOut()
    {
        isSwap = false; // 무기 스왑 상태 해제
    }

    private void Interaction()
    {
        if (nearObject != null && nearObject.CompareTag("Weapon"))
        {
            Item item = nearObject.GetComponent<Item>();
            int weaponIndex = item.value; // Item value 설정한 값 (0, 1, 2)
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
                // 모든 무기의 탄약을 최대로 채우기
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
            Debug.Log("Player has reached the platform.");
            GameManager.Instance.LoadNextScene(); // GameManager를 통해 씬 전환
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
            TakeDamage(10); // 적과 충돌 시 10의 체력 감소
        }
    }

    private void TakeDamage(int damage)
    {
        currentHealth -= damage;
        if (currentHealth <= 0 && !isDead)
        {
            StartCoroutine(Die());
        }
    }

    private IEnumerator Die()
    {
        isDead = true;
        Debug.Log("Player Died");

        // 카메라를 하늘로 회전
        float elapsedTime = 0f;
        while (elapsedTime < deathDuration)
        {
            float angle = Mathf.Lerp(0, -45, elapsedTime / deathDuration);
            cam.localRotation = Quaternion.Euler(angle, 0f, 0f);
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        // 사망 연출 후 추가 처리 (예: 게임 오버 화면 표시, 재시작 등)
        // GameOver();
    }

    private void Attack()
    {
        if (Input.GetMouseButtonDown(0) && equipWeapon != null) // 왼쪽 마우스 버튼을 눌렀을 때
        {
            equipWeapon.Use(); // 무기 사용
        }
    }

    // 씬이 로드될 때 호출되는 메서드
    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        // 씬 별 시작 위치 설정
        if (scene.name == "stage1")
        {
            SetPlayerStartPosition(new Vector3(-16.63f, 1.49f, 3.6f));
        }
        else if (scene.name == "stage2")
        {
            SetPlayerStartPosition(new Vector3(-18.78f, 6.93f, -22.97f));
        }
        // 추가적인 씬을 위한 시작 위치를 여기에 추가할 수 있습니다.

        // Crosshair 초기화
        InitializeCrosshair();

        // 씬 로드 시 초기화해야 하는 오브젝트 관리
        if (GameManager.Instance != null)
        {
            GameManager.Instance.OnSceneLoaded(scene);
        }
    }

    // 시작 위치 설정 메서드
    private void SetPlayerStartPosition(Vector3 startPosition)
    {
        controller.enabled = false; // 이동 중 오류 방지를 위해 CharacterController 비활성화
        transform.position = startPosition;
        controller.enabled = true; // 위치 설정 후 CharacterController 다시 활성화
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
                crosshair.enabled = false; // 초기화 시 Crosshair 비활성화
                DontDestroyOnLoad(crosshair.gameObject); // Crosshair를 DontDestroyOnLoad로 설정
            }
            else
            {
                Debug.LogError("Crosshair not found in the scene!");
            }
        }
    }

    private void OnDestroy()
    {
        SceneManager.sceneLoaded -= OnSceneLoaded;
    }
}
