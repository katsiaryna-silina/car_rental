package by.itacademy.javaenterprise.carrental.silina.controller;

import by.itacademy.javaenterprise.carrental.silina.repository.model.User;
import by.itacademy.javaenterprise.carrental.silina.repository.model.UserDetails;
import by.itacademy.javaenterprise.carrental.silina.service.OrderService;
import by.itacademy.javaenterprise.carrental.silina.service.RoleService;
import by.itacademy.javaenterprise.carrental.silina.service.UserDetailsService;
import by.itacademy.javaenterprise.carrental.silina.service.UserService;
import by.itacademy.javaenterprise.carrental.silina.service.dto.UserDTO;
import by.itacademy.javaenterprise.carrental.silina.service.dto.UserDetailsDTO;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

import static by.itacademy.javaenterprise.carrental.silina.constant.HandlerConstants.USERS_URL;

@Controller
@RequestMapping(USERS_URL)
@AllArgsConstructor
public class UserController {
    private final UserService userService;
    private final UserDetailsService userDetailsService;
    private final RoleService roleService;
    private final OrderService orderService;

    @GetMapping
    public String getAllOrders(Model model) {
        model.addAttribute("users", userService.getAllUserDTOs());
        return "users";
    }

    @PostMapping("/updateUser")
    public String saveUser(@ModelAttribute UserDTO userDTO) {
        userService.updateUserRoleAndEnabledStatusFrom(userDTO);
        return "redirect:/users";
    }

    @GetMapping("/updateform")
    public String showUpdateForm(@RequestParam Long userId, Model model) {
        var userDTO = userService.getUserDTOById(userId);
        model.addAttribute("user", userDTO);
        model.addAttribute("userRoles", roleService.getAllRoleDTOs());
        return "update_user_form";
    }

    @GetMapping("/registration")
    public String redirectToAddUser(@ModelAttribute("user") User user,
                                    @ModelAttribute("userDetails") UserDetails userDetails) {
        return "user_registration";
    }

    @PostMapping("/registration")
    public String addUser(@RequestBody @ModelAttribute("user") @Valid User user,
                          BindingResult resultUser,
                          @RequestBody @ModelAttribute("userDetails") @Valid UserDetails userDetails,
                          BindingResult resultUserDetails) {
        if (resultUser.hasErrors() || resultUserDetails.hasErrors()) {
            return "user_registration";
        } else {
            userDetailsService.add(userDetails);
            user.setUserDetails(userDetails);
            userService.addClient(user);
            return "user_success_registration";
        }
    }

    @GetMapping("/userInfo")
    public String showUserInfo(Model model) {
        var userId = userService.getPrincipalUserId();
        var userDTO = userService.getUserDTOById(userId);
        model.addAttribute("user", userDTO);
        return "user_info";
    }

    @GetMapping("/changeUserInfo")
    public String changeUserInfo(@RequestParam Long userId, Model model) {
        var userDetailsDTO = userDetailsService.getUserDetailsDTOById(userId);
        model.addAttribute("userDetails", userDetailsDTO);
        return "user_info_change_form";
    }

    @PostMapping("/")
    public String updateUserInfo(@RequestBody @ModelAttribute("userDetails") @Valid UserDetailsDTO userDetailsDTO,
                                 BindingResult resultUserDetailsDTO) {
        if (resultUserDetailsDTO.hasErrors()) {
            return "user_info_change_form";
        } else {
            userDetailsService.changeUserDetailsFrom(userDetailsDTO);
            return "user_info_success_change";
        }
    }

    @GetMapping("/password/form")
    public String changeUserPassword(@RequestParam Long userId, Model model) {
        var userDTO = userService.getUserDTOById(userId);
        userDTO.setPassword("");
        model.addAttribute("user", userDTO);
        return "user_password_change_form";
    }

    @PostMapping("/password/form")
    public String updateUserInfo(@RequestBody @ModelAttribute("user") @Valid UserDTO userDTO,
                                 BindingResult resultUserDTO) {
        if (resultUserDTO.hasErrors()) {
            return "user_password_change_form";
        } else {
            userService.changeUserPasswordFrom(userDTO);
            return "user_password_success_change";
        }
    }

    @GetMapping("/delete")
    public String deleteUser(@RequestParam Long userId) {
        var user = userService.getUserById(userId);
        if (user.getOrders().size() == 0) {
            userService.deleteUserById(userId);
        } else {
            userService.changeUserEnabledStatus(userId, false);
        }
        return "redirect:/logout";
    }

    @GetMapping("/userOrders")
    public String showUserOrders(Model model) {
        var userId = userService.getPrincipalUserId();
        var orderDTOS = orderService.getUserOrdersDTOsByUserId(userId);
        model.addAttribute("orders", orderDTOS);
        return "user_orders";
    }

    @GetMapping("/payment")
    public String payForOrder(@RequestParam Long orderId) {
        orderService.changeOrderStatusFromWaitingForPaymentToPaid(orderId);
        return "redirect:/users/userOrders";
    }

    @GetMapping("/decline")
    public String declineOrder(@RequestParam Long orderId) {
        orderService.changeOrderStatusFromWaitingForPaymentToCanceledByClient(orderId);
        return "redirect:/users/userOrders";
    }
}
