using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class Weapon : MonoBehaviour
{
    public enum Type { Range }; // 무기 유형
    public enum RangeType { Rifle, Shotgun, Sniper }; // 추가된 세부 타입
    public Type type; // 무기 유형 변수
    public RangeType rangeType; // 세부 타입 변수
    public int damage; // 데미지
    public int maxAmmo; // 최대 탄 개수
    public int curAmmo; // 현재 남아 있는 탄 개수

    public Camera playerCamera; // 플레이어 카메라
    public AudioClip gunshotClip; // 발사 사운드 클립 추가
    private AudioSource audioSource; // AudioSource 컴포넌트

    public Text ammoText; // UI Text 컴포넌트

    private float lastShotTime; // 마지막으로 발사한 시간
    private float cooldown; // 무기별 쿨타임

    void Start()
    {
        // 무기 타입별 쿨타임 설정
        if (type == Type.Range)
        {
            switch (rangeType)
            {
                case RangeType.Rifle:
                    cooldown = 0.3f;
                    break;
                case RangeType.Shotgun:
                    cooldown = 1.0f;
                    break;
                case RangeType.Sniper:
                    cooldown = 2.0f;
                    break;
            }
        }

        lastShotTime = -cooldown; // 게임 시작 시 바로 쏠 수 있도록 초기화
        audioSource = GetComponent<AudioSource>(); // AudioSource 컴포넌트 할당

        UpdateAmmoText(); // 초기 탄 개수 UI 업데이트
    }

    // 플레이어가 무기 사용
    public void Use()
    {
        if (type == Type.Range && Time.time - lastShotTime >= cooldown && curAmmo > 0) // 쿨타임이 지났고 탄 개수가 0보다 클 때
        {
            lastShotTime = Time.time; // 마지막 발사 시간 갱신
            curAmmo--;
            UpdateAmmoText(); // 탄 개수 UI 업데이트
            StartCoroutine(Shot());
        }
    }

    IEnumerator Shot()
    {
        // 발사 사운드 재생
        if (gunshotClip != null && audioSource != null)
        {
            audioSource.PlayOneShot(gunshotClip);
        }

        // 발사 로직
        Ray ray = playerCamera.ViewportPointToRay(new Vector3(0.5f, 0.5f, 0f)); // 화면 중앙에서 Ray 발사
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit))
        {
            Enemy enemy = hit.collider.GetComponent<Enemy>();
            if (enemy != null)
            {
                enemy.TakeDamage(damage);
            }

            Boss boss = hit.collider.GetComponent<Boss>();
            if (boss != null)
            {
                boss.TakeDamage(damage);
            }
        }

        yield return null;
    }

    void UpdateAmmoText()
    {
        if (ammoText != null)
        {
            ammoText.text = "Ammo: " + curAmmo + "/" + maxAmmo; // 탄약 텍스트 업데이트
        }
    }
}
