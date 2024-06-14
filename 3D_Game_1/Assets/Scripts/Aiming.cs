using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PlayerAiming : MonoBehaviour
{
    public Transform aimPosition; // 조준할 때 무기를 이동시킬 위치
    public float aimSpeed = 5f; // 조준 속도
    public Camera playerCamera; // 주 카메라
    public float aimFOV = 30f; // 일반 무기 조준 시 시야각
    public float sniperAimFOV = 15f; // 스나이퍼 무기 조준 시 시야각
    private float defaultFOV; // 기본 시야각
    private Vector3 defaultWeaponPosition; // 기본 무기 위치
    public bool isSniper = false; // 스나이퍼 무기 여부

    private bool isAiming = false; // 플레이어가 조준 중인지 여부

    public Image crosshair; // 조준점 이미지

    public Weapon currentWeapon; // 현재 장착된 무기

    private void Start()
    {
        // 기본 시야각과 무기 위치 저장
        if (playerCamera != null)
        {
            defaultFOV = playerCamera.fieldOfView;
        }

        if (aimPosition != null)
        {
            defaultWeaponPosition = transform.localPosition;
        }

        // 조준점 비활성화
        if (crosshair != null)
        {
            crosshair.enabled = false;
        }
    }

    private void Update()
    {
        if (currentWeapon != null) // 무기가 있을 때만 조준 가능
        {
            Aim();
        }
    }

    private void Aim()
    {
        if (Input.GetMouseButtonDown(1)) // 오른쪽 마우스 버튼을 눌렀을 때
        {
            isAiming = true;
            if (crosshair != null)
            {
                crosshair.enabled = true; // 조준점 활성화
            }
        }

        if (Input.GetMouseButtonUp(1)) // 오른쪽 마우스 버튼을 뗐을 때
        {
            isAiming = false;
            if (crosshair != null)
            {
                crosshair.enabled = false; // 조준점 비활성화
            }
        }

        if (isAiming)
        {
            // 무기를 조준 위치로 부드럽게 이동
            transform.localPosition = Vector3.Lerp(transform.localPosition, aimPosition.localPosition, Time.deltaTime * aimSpeed);

            // 카메라 시야각을 조준용으로 변경
            if (playerCamera != null)
            {
                playerCamera.fieldOfView = Mathf.Lerp(playerCamera.fieldOfView, isSniper ? sniperAimFOV : aimFOV, Time.deltaTime * aimSpeed);
            }
        }
        else
        {
            // 무기를 기본 위치로 부드럽게 이동
            transform.localPosition = Vector3.Lerp(transform.localPosition, defaultWeaponPosition, Time.deltaTime * aimSpeed);

            // 카메라 시야각을 기본값으로 복원
            if (playerCamera != null)
            {
                playerCamera.fieldOfView = Mathf.Lerp(playerCamera.fieldOfView, defaultFOV, Time.deltaTime * aimSpeed);
            }
        }
    }
}
