using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class Player : MonoBehaviour
{
    public static Player Instance { get; private set; }

    public float walkSpeed = 5f; // �ȱ� �ӵ�
    public float runSpeed = 10f; // �޸��� �ӵ�
    public float jumpForce = 5f; // ���� ��
    public CharacterController controller; // ĳ���� ��Ʈ�ѷ� ������Ʈ
    public Transform cam; // ī�޶� Transform
    public Transform weaponPoint; // ���� ���� ��ġ

    public GameObject[] weapons; // ���� �迭
    public bool[] hasWeapons; // ���� ���� ����
    public int ammo; // ���� ź��
    public int maxAmmo; // �ִ� ź��

    public int maxHealth = 100; // �ִ� ü��
    private int currentHealth; // ���� ü��
    private bool isDead = false; // �÷��̾� ��� ����
    public float deathLookUpSpeed = 2f; // ��� �� �ϴ��� �ٶ󺸴� �ӵ�
    public float deathDuration = 2f; // ��� ���� ���� �ð�

    public string stage2SceneName = "stage2"; // stage2 �� �̸�
    public string bossStageSceneName = "bossStage"; // bossStage �� �̸�

    public Image crosshair; // ������ �̹���

    private Vector3 moveDirection; // �̵� ���� ����
    private float gravity = 9.81f; // �߷� ��
    private float yVelocity = 0f; // Y �� �ӵ� (�߷� �� ����)
    private int jumpCount = 0; // ���� ���� Ƚ��
    private int maxJumpCount = 2; // �ִ� ���� Ƚ�� (���� ����)

    private float xRotation = 0f; // X �� ȸ�� �� (ī�޶� ȸ��)
    public float mouseSensitivity = 100f; // ���콺 ����

    private bool sDown1; // ���� ���� 1�� Ű �Է�
    private bool sDown2; // ���� ���� 2�� Ű �Է�
    private bool sDown3; // ���� ���� 3�� Ű �Է�
    private bool isSwap; // ���� ���� ���� ����

    private Weapon equipWeapon; // ���� ������ ����
    private int equipWeaponIndex = -1; // ���� ������ ���� �ε���

    private GameObject nearObject; // ��ó ������Ʈ

    private PlayerAiming playerAiming; // PlayerAiming ������Ʈ

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

        // Crosshair�� DontDestroyOnLoad�� ����
        if (crosshair != null)
        {
            DontDestroyOnLoad(crosshair.gameObject);
        }
    }

    private void Start()
    {
        // �� �ε� �̺�Ʈ ���
        SceneManager.sceneLoaded += OnSceneLoaded;

        // ĳ���� ��Ʈ�ѷ� ������Ʈ ��������
        controller = GetComponent<CharacterController>();
        // PlayerAiming ������Ʈ ��������
        playerAiming = GetComponent<PlayerAiming>();
        if (playerAiming == null)
        {
            Debug.LogError("PlayerAiming component is missing!");
        }

        // Ŀ���� ȭ�� �߾ӿ� �����ϰ� ����
        Cursor.lockState = CursorLockMode.Locked;

        // ����� �α׷� ���� �迭 Ȯ��
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

        currentHealth = maxHealth; // �ʱ� ü�� ����

        // Crosshair ����
        if (crosshair != null)
        {
            crosshair.enabled = false; // �ʱ�ȭ �� Crosshair ��Ȱ��ȭ
        }
    }

    private void Update()
    {
        if (!isDead)
        {
            Move(); // �̵� ó��
            Jump(); // ���� ó��
            Rotate(); // ȸ�� ó��
            GetInput(); // �Է� ó��
            Swap(); // ���� ��ü
            Interaction(); // ��ȣ�ۿ�
            Attack(); // ���� ó��
        }

        if (equipWeapon != null && Input.GetMouseButtonDown(1))
        {
            // ������ ���콺 ��ư�� ������ ���� ���� ��ȯ
            Aim(true);
        }
        else if (Input.GetMouseButtonUp(1))
        {
            // ������ ���콺 ��ư�� ���� ���� ��带 ����
            Aim(false);
        }
    }

    private void Move()
    {
        float horizontal = Input.GetAxis("Horizontal"); // ���� �Է� (A, D �Ǵ� �¿� ȭ��ǥ Ű)
        float vertical = Input.GetAxis("Vertical"); // ���� �Է� (W, S �Ǵ� ���� ȭ��ǥ Ű)

        Vector3 direction = new Vector3(horizontal, 0f, vertical).normalized; // �Է� ���� ���� ���
        float currentSpeed = Input.GetKey(KeyCode.LeftShift) ? runSpeed : walkSpeed; // �޸���/�ȱ� �ӵ� ����

        if (direction.magnitude >= 0.1f)
        {
            Vector3 moveDir = transform.right * horizontal + transform.forward * vertical; // �̵� ���� ���� ��� (���� ��ǥ�� ����)
            controller.Move(moveDir * currentSpeed * Time.deltaTime); // ĳ���� �̵�
        }

        // �߷� ����
        if (controller.isGrounded)
        {
            if (yVelocity < 0)
            {
                yVelocity = -gravity * Time.deltaTime; // ���鿡 ���� �� �߷� �ʱ�ȭ
                jumpCount = 0; // ���鿡 ���� �� ���� Ƚ�� �ʱ�ȭ
            }
        }
        else
        {
            yVelocity -= gravity * Time.deltaTime; // ���߿� ���� �� �߷� ����
        }

        moveDirection.y = yVelocity; // �̵� ���⿡ Y �� �ӵ� ����
        controller.Move(moveDirection * Time.deltaTime); // ĳ���� �̵�
    }

    private void Rotate()
    {
        float mouseX = Input.GetAxis("Mouse X") * mouseSensitivity * Time.deltaTime; // ���콺 X �� �Է�
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity * Time.deltaTime; // ���콺 Y �� �Է�

        xRotation -= mouseY; // X �� ȸ�� �� ����
        xRotation = Mathf.Clamp(xRotation, -90f, 90f); // X �� ȸ�� �� ���� (���� 90�� ����)

        cam.localRotation = Quaternion.Euler(xRotation, 0f, 0f); // ī�޶� ȸ�� ����
        transform.Rotate(Vector3.up * mouseX); // ĳ���� ȸ�� ����
    }

    private void Jump()
    {
        if (Input.GetButtonDown("Jump") && jumpCount < maxJumpCount)
        {
            yVelocity = jumpForce; // ���� �� ����
            jumpCount++; // ���� Ƚ�� ����
        }
    }

    private void GetInput()
    {
        sDown1 = Input.GetButtonDown("Swap1"); // ���� ���� 1�� Ű �Է�
        sDown2 = Input.GetButtonDown("Swap2"); // ���� ���� 2�� Ű �Է�
        sDown3 = Input.GetButtonDown("Swap3"); // ���� ���� 3�� Ű �Է�
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

                    // ���⸦ �տ� ���̱�
                    if (weaponPoint != null)
                    {
                        equipWeapon.transform.SetParent(weaponPoint);
                        equipWeapon.transform.localPosition = Vector3.zero; // ��ġ �ʱ�ȭ
                        equipWeapon.transform.localRotation = Quaternion.identity; // ȸ�� �ʱ�ȭ
                    }
                    else
                    {
                        // ���� ���� ��ġ�� ���� ���, ī�޶� �տ� ���� ��ġ
                        equipWeapon.transform.SetParent(cam);
                        equipWeapon.transform.localPosition = new Vector3(0.5f, -0.5f, 1f); // ������ ��ġ ����
                        equipWeapon.transform.localRotation = Quaternion.identity;
                    }

                    if (playerAiming != null)
                    {
                        playerAiming.currentWeapon = equipWeapon; // PlayerAiming�� ���� ���� ����
                    }
                    else
                    {
                        Debug.LogError("PlayerAiming component is missing!");
                    }

                    isSwap = true;
                    Invoke("SwapOut", 0.4f); // 0.4�� �� SwapOut �Լ� ȣ��
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
        isSwap = false; // ���� ���� ���� ����
    }

    private void Interaction()
    {
        if (nearObject != null && nearObject.CompareTag("Weapon"))
        {
            Item item = nearObject.GetComponent<Item>();
            int weaponIndex = item.value; // Item value ������ �� (0, 1, 2)
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
                // ��� ������ ź���� �ִ�� ä���
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
            GameManager.Instance.LoadNextScene(); // GameManager�� ���� �� ��ȯ
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
            TakeDamage(10); // ���� �浹 �� 10�� ü�� ����
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

        // ī�޶� �ϴ÷� ȸ��
        float elapsedTime = 0f;
        while (elapsedTime < deathDuration)
        {
            float angle = Mathf.Lerp(0, -45, elapsedTime / deathDuration);
            cam.localRotation = Quaternion.Euler(angle, 0f, 0f);
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        // ��� ���� �� �߰� ó�� (��: ���� ���� ȭ�� ǥ��, ����� ��)
        // GameOver();
    }

    private void Attack()
    {
        if (Input.GetMouseButtonDown(0) && equipWeapon != null) // ���� ���콺 ��ư�� ������ ��
        {
            equipWeapon.Use(); // ���� ���
        }
    }

    // ���� �ε�� �� ȣ��Ǵ� �޼���
    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        // �� �� ���� ��ġ ����
        if (scene.name == "stage1")
        {
            SetPlayerStartPosition(new Vector3(-16.63f, 1.49f, 3.6f));
        }
        else if (scene.name == "stage2")
        {
            SetPlayerStartPosition(new Vector3(-18.78f, 6.93f, -22.97f));
        }
        // �߰����� ���� ���� ���� ��ġ�� ���⿡ �߰��� �� �ֽ��ϴ�.

        // Crosshair �ʱ�ȭ
        InitializeCrosshair();

        // �� �ε� �� �ʱ�ȭ�ؾ� �ϴ� ������Ʈ ����
        if (GameManager.Instance != null)
        {
            GameManager.Instance.OnSceneLoaded(scene);
        }
    }

    // ���� ��ġ ���� �޼���
    private void SetPlayerStartPosition(Vector3 startPosition)
    {
        controller.enabled = false; // �̵� �� ���� ������ ���� CharacterController ��Ȱ��ȭ
        transform.position = startPosition;
        controller.enabled = true; // ��ġ ���� �� CharacterController �ٽ� Ȱ��ȭ
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
                crosshair.enabled = false; // �ʱ�ȭ �� Crosshair ��Ȱ��ȭ
                DontDestroyOnLoad(crosshair.gameObject); // Crosshair�� DontDestroyOnLoad�� ����
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
